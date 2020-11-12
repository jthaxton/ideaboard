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
        binding.pry
        call_with_idea(IdeaDomain::Commands::CreateIdea)
        render :ok
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
        params.require(:idea).permit(:title, :body)
      end
    end
  end
end
