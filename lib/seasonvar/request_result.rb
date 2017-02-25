module Seasonvar
  class RequestResult
    attr_reader :client
    attr_reader :request_content
    attr_reader :response_raw
    attr_reader :response_content
    attr_reader :status_code
    attr_reader :response_headers
    attr_reader :start_time
    attr_reader :end_time

    def initialize(client, request_content, response_raw, response_content,
                   status_code, response_headers, start_time, end_time) # :nodoc:
      @client = client
      @request_content = request_content
      @response_raw = response_raw
      @response_content = response_content
      @status_code = status_code
      @response_headers = response_headers
      @start_time = start_time
      @end_time = end_time
    end

    def time_taken
      end_time - start_time
    end

    def key
      client.key
    end
  end
end
