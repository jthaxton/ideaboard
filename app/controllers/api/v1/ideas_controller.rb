# frozen_string_literal: true

module Api
  module V1
    class IdeasController < ApplicationController
      include DomainController

      # def index
      #   @ideas = Idea.all
      #   render json: @ideas
      # end

      # def create
      #   @idea = Idea.create(idea_params)
      #   render json: @idea
      # end

      # def update
      #   @idea = Idea.find(params[:id])
      #   @idea.update_attributes(idea_params)
      #   render json: @idea
      # end

      # ES CREATE
      def create
        call_with_idea(IdeaDomain::Commands::CreateIdea)
        render :ok
      end

      def create_idea
        stream_name = "idea#{idea_params[:id]}"
        event = IdeaDomain::Events::CreateIdea.new(data: {
          id: idea_params[:id],
          title: idea_params[:title],
          body: idea_params[:body],
        })

        #publishing an event for a specific stream
        Rails.configuration.event_store.publish(event, stream_name: stream_name)
      end


      # ES SHOW
      def show
        idea = idea_repository.find(21)
        render json: idea
      end

      private

      def call_with_idea(command_type)
        call(command_type.new(command_params))
      end

      def idea_repository
        Rails.configuration.idea_repository
      end

      def idea_params
        params.permit(:title, :body, :id, :idea_id)
      end
    end
  end
end
