# coding: utf-8
module Seasonvar
  class Client
    attr_reader :domain
    attr_reader :scheme
    attr_reader :port
    attr_reader :read_timeout
    attr_reader :connection_timeout
    attr_reader :adapter

    def initialize(params = {})
      @domain = params[:domain] || 'api.seasonvar.ru'
      @scheme = 'http'
      @port = 80
      @read_timeout = params[:read_timeout] || 60
      @connection_timeout = params[:connection_timeout] || 60
      @adapter = params[:adapter] || :net_http_persistent
      @key = params[:key]

      init_connection
    end

    def countries
      execute(command: 'getCountryList')
    end

    def genres
      execute(command: 'getGenreList')
    end

    def updates(params = {})
      days = params[:days] || 7
      season_info = params[:season_info] || false
      execute(command: 'getUpdateList', day_count: days, seasonInfo: season_info)
    end

    def list_series(params = {})
      data = {}
      data[:country] = params[:countries] if params[:countries]
      data[:genre] = params[:genres] if params[:genres]
      if [:domestic, :foreign].include?(params[:locale])
        data[:locale] = params[:locale]
      end
      if [:kinopoisk, :imdb, :popular, :year].include?(params[:order])
        sort = {}
        sort[:order] = params[:order]
        sort[:method] = 'desc' if params[:desc]
        data[:sort] = sort
      end
      data[:lastSeasonInfo] = true if params[:season_info]
      data[:letter] = params[:prefix] if params[:prefix]
      execute(data.merge(command: 'getSerialList'))
    end

    def series(params = {})
      data = if params[:id]
               { id: params[:id] }
             elsif params[:name]
               { name: params[:name] }
             elsif params[:prefix]
               { letter: params[:prefix] }
             end
      raise ArgumentError, 'id, name or prefix have to be specified' unless data
      execute(data.merge(command: 'getSeasonList'))
    end

    def season(params = {})
      season_id = params[:id]
      raise ArgumentError, 'id have to be specified' unless season_id
      execute(command: 'getSeason', season_id: season_id)
    end

    def search(params = {})
      raise ArgumentError, 'query have to be specified' unless params[:query]
      data = { command: 'search', query: params[:query] }
      data[:country] = params[:countries] if params[:countries]
      data[:genre] = params[:genres] if params[:genres]
      execute(data)
    end

    private

    def execute(data)
      start_time = Time.now
      request_content = data.merge(key: @key)
      begin
        response = @connection.send(:post) do |req|
          req.body = URI.encode_www_form(request_content)
          req.url('')
        end
      rescue Faraday::ClientError => e
        message = e.class.name
        message += ": #{e.message}" unless e.message.nil?
        raise message
      end
      end_time = Time.now

      response_raw = response.body
      response_content = JSON.parse(response_raw)
      raise 'Invalid JSON.' if response_content.nil? && response.status != 503
      RequestResult.new(self, request_content, response_raw, response_content,
                        response.status, response.headers, start_time, end_time)
    end

    def init_connection
      @connection = Faraday.new(
        url: "#{scheme}://#{domain}:#{port}/",
        headers: {
          'Accept-Encoding' => 'gzip,deflate',
          'Content-Type' => 'application/x-www-form-urlencoded',
          'User-Agent' => "seasonvar.rb/#{Seasonvar::VERSION}"
        },
        request: { timeout: read_timeout, open_timeout: connection_timeout }
      ) do |conn|
        conn.adapter(*Array(adapter))
        conn.response :seasonvar_decode
      end
    end
  end

  class SeasonvarDecode < Faraday::Middleware # :nodoc:
    def call(env)
      @app.call(env).on_complete do |response_env|
        raw_body = response_env[:body]
        response_env[:body] =
          case response_env[:response_headers]['Content-Encoding']
          when 'gzip'
            io = StringIO.new raw_body
            Zlib::GzipReader.new(io, external_encoding: Encoding::UTF_8).read
          when 'deflate'
            Zlib::Inflate.inflate raw_body
          else
            raw_body
          end
      end
    end
  end

  Faraday::Response.register_middleware seasonvar_decode: -> { SeasonvarDecode }
end
