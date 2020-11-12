# frozen_string_literal: true
class DomainRepository < AggregateRoot::Repository
  DEFAULT_BATCH_SIZE = 64
  def load(aggregate_spec, stream_name, batch_size = DEFAULT_BATCH_SIZE)
    aggregate = restore_snapshot(aggregate_spec, stream_name, batch_size)
    if aggregate.version <= -1
      reload!(aggregate, stream_name, batch_size)
    end
    aggregate
  end

  def load_until(aggregate, stream_name, date, batch_size = DEFAULT_BATCH_SIZE)
    reload!(aggregate, stream_name, batch_size) { |event| DateTime.parse(event.metadata[:timestamp]) <= date }
  end

  def store(aggregate, stream_name, batch_size = DEFAULT_BATCH_SIZE)
    new_events_count = aggregate.unpublished_events.count
    binding.pry
    if aggregate.unpublished_events.count > 0
      binding.pry
      last_event_id = aggregate.unpublished_events.to_a[0].event_id
      super(aggregate, stream_name)
      take_snapshot?(aggregate, stream_name, new_events_count, last_event_id, batch_size)
    else
      super(aggregate, stream_name)
    end
  end

  def with_aggregate(aggregate_spec, stream_name, batch_size = DEFAULT_BATCH_SIZE, &block)
    aggregate = load(aggregate_spec, stream_name, batch_size)
    result = block.call(aggregate)
    store(aggregate, stream_name, batch_size)
    result
  end

  private

  def reload!(aggregate, stream_name, batch_size = DEFAULT_BATCH_SIZE, &block)
    binding.pry
    event_store.read.stream(stream_name).in_batches(batch_size).reduce do |_, event|
      aggregate.apply(event) if !block_given? || block.call(event)
    end
    aggregate.version = aggregate.unpublished_events.count - 1
    aggregate
  end

  def restore_snapshot(aggregate, stream_name, batch_size = DEFAULT_BATCH_SIZE)
    snapshot = StreamSnapshot.where(stream_name: stream_name).first
    return aggregate if snapshot.blank?
    foo_aggregate = Marshal.load(Base64.decode64(snapshot.data))
    aggregate = foo_aggregate
    aggregate.version = snapshot.version
    event_store.read.stream(stream_name).in_batches(batch_size).from(snapshot.event_id).reduce do |_, ev|
      aggregate.apply(ev)
      aggregate.version = aggregate.version + 1
    end
    aggregate
  end

  def take_snapshot?(aggregate, stream_name, _new_events_count, last_event_id, batch_size)
    snapshot = StreamSnapshot.where(stream_name: stream_name).first
    do_snapshot = snapshot.blank? ? aggregate.version >= batch_size : aggregate.version - snapshot.version >= batch_size

    if do_snapshot
      encoded_string = Base64.encode64(Marshal.dump(aggregate))
      version = aggregate.version
      if snapshot.present?
        snapshot.update(event_id: last_event_id, version: version, data: encoded_string)
      else
        StreamSnapshot.create(stream_name: stream_name, event_id: last_event_id, version: version, data: encoded_string)
      end
    end
  end
end