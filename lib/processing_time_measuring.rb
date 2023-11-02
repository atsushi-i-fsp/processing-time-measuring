# frozen_string_literal: true

require 'benchmark'

require_relative "processing_time_measuring/version"

module ProcessingTimeMeasuring
  class Error < StandardError; end

  @scores = {}

  def self.init
    @scores = {}
  end

  def self.mesure(message, &block)
    @scores[message] ||= []
    result = Benchmark.measure(&block)
    @scores[message] << result

    Rails.logger.info "-- #{message} -----"
    Rails.logger.info Benchmark::CAPTION
    Rails.logger.info result.to_s
    result
  end

  def self.puts_all_results
    Rails.logger.info "[ALL RESULT] -----"
    @scores.each do |key, bm_results|
      Rails.logger.info "-- #{key} -----"
      Rails.logger.info "Mesure #{bm_results.size} times"
      Rails.logger.info "Average"
      Rails.logger.info average(bm_results).to_s
      Rails.logger.info "Total"
      Rails.logger.info total(bm_results).to_s
    end
  end

  def self.average(bm_results)
    if bm_results.nil? || bm_results.size <= 0
      return nil
    end

    size = bm_results.size
    utime = 0
    stime = 0
    cutime = 0
    cstime = 0
    real = 0

    bm_results.each do |bm_result|
      utime += bm_result.utime
      stime += bm_result.stime
      cutime += bm_result.cutime
      cstime += bm_result.cstime
      real += bm_result.real
    end

    Benchmark::Tms.new(utime / size, stime / size, cutime / size, cstime / size, real / size)
  end

  def self.total(bm_results)
    reutrn nil if bm_results.nil?

    utime = 0
    stime = 0
    cutime = 0
    cstime = 0
    real = 0

    bm_results.each do |bm_result|
      utime += bm_result.utime
      stime += bm_result.stime
      cutime += bm_result.cutime
      cstime += bm_result.cstime
      real += bm_result.real
    end

    Benchmark::Tms.new(utime, stime, cutime, cstime, real)
  end
end
