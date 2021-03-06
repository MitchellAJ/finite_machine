# encoding: utf-8

RSpec.describe FiniteMachine do
  include RSpec::Benchmark::Matchers

  class Measurement
    attr_reader :steps, :loops

    def initialize
      @steps = 0
      @loops = 0
    end

    def inc_step
      @steps += 1
    end

    def inc_loop
      @loops += 1
    end
  end

  it "correctly loops through events" do
    measurement = Measurement.new

    fsm = FiniteMachine.define do
      initial :green

      target(measurement)

      events {
        event :next, :green => :yellow,
                     :yellow => :red,
                     :red => :green
      }

      callbacks {
        on_enter do |event| target.inc_step; true end
        on_enter :red do |event| target.inc_loop; true end
      }
    end

    100.times { fsm.next }

    expect(measurement.steps).to eq(100)
    expect(measurement.loops).to eq(100 / 3)
  end

  it "performs at least 300 ips" do
    fsm = FiniteMachine.define do
      initial :green

      events {
        event :next, :green => :yellow,
                     :yellow => :red,
                     :red => :green
      }
    end

    expect { fsm.next }.to perform_at_least(300).ips
  end
end
