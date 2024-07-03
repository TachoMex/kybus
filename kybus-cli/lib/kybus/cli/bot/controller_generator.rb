# frozen_string_literal: true

module Kybus
  class CLI < Thor
    class Bot < Thor
      class ControllerGenerator
        def initialize(name)
          @name = name
          @file_writer = Kybus::CLI::FileWriter.new('routes')
        end

        def generate
          @file_writer.write("#{@name}_controller.rb", controller_content)
        end

        private

        def controller_content
          <<~RUBY
            # frozen_string_literal: true

            module #{@name.capitalize}Controller
              def self.included(base)
                base.instance_eval do
                  include Routes

                  def #{@name}_routes
                    # Define your routes here
                  end
                end
              end
            end
          RUBY
        end
      end
    end
  end
end
