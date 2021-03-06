class RuntimesController < ApplicationController
  def index
    @runtimes = Runtime.all
    render json: @runtimes

    # Thread.new{
    #   while 1 do
    #     sleep(2)
    #     puts 'runtime stop'
    #   end
    # }
  end

  def show
    if params[:jsonpath].blank?
      @runtime = Runtime.find_by_describe(params[:describe])
      render json: @runtime
    else
      @runtime = Runtime.find_by_describe(params[:describe])
      jsonpath = xtoy(params[:jsonpath])
      path = JsonPath.new(jsonpath)
      value = path.on(@runtime.as_json)[0]
      obj = {'jsonvalue' => value}
      render json: obj
    end
  end

  def create
    @runtime = Runtime.new()
    @runtime.runtimes = params[:runtimes]
    @runtime.describe = params[:describe]
    if @runtime.save!
      render json: @runtime, status: :created
    else
      render json: @runtime.errors, status: :unprocessable_entity
    end
  end

  def add
    @runtime = Runtime.find_by_describe(params[:describe])
    jsonpathd = params[:jsonpath]
    jsonvalue = params[:value]
    jsonpath = dtoy(jsonpathd)
    path = JsonPath.new(jsonpath)
    value = path.on(@runtime.as_json)[0]
    newjsonvalue = value.merge jsonvalue
    @runtimenew = JsonPath.for(@runtime.as_json).gsub(jsonpath) {|v| newjsonvalue }.to_hash
    @runtime.update(@runtimenew)
    render json: newjsonvalue
  end

  def alert
    if !(params[:create_time].nil?)
      @history_data = HistoryDatum.new()
      @history_data.describe = params[:name]
      @history_data.data = params[:value]
      @history_data.create_time = params[:create_time]
      @history_data.save
    end

    @runtime = Runtime.find_by_describe(params[:describe])
    jsonpathd = params[:jsonpath]
    jsonvalue = params[:value]
    jsonpath = dtoy(jsonpathd)
    path = JsonPath.new(jsonpath)
    if path.on(@runtime.as_json)[0] == jsonvalue
      puts 'equal'
      render json: @runtime
    else
      puts 'different'
      @runtimenew = JsonPath.for(@runtime.as_json).gsub(jsonpath) {|v| jsonvalue }.to_hash
      @runtime.update(@runtimenew)
      obj = {jsonpathd => jsonvalue}
      objs = jtom(obj.to_s)
      key = params[:describe] + "." + jsonpathd

      conn = Bunny.new(
          :host => "192.168.4.175",
          :port => 5672,
          :ssl       => false,
          :vhost     => "/",
          :user      => "admin",
          :pass      => "admin",
          :heartbeat => :server, # will use RabbitMQ setting
          :frame_max => 131072,
          :auth_mechanism => "PLAIN"
      )
      conn.start
      ch   = conn.create_channel
      x    = ch.topic("amq.topic")
      # x    = ch.topic("topic_logs")
      x.publish(objs, :routing_key => key)
      puts objs
      conn.close
      render json: @runtime
    end
  end

  def delete
    if params[:jsonpath].blank?
      @runtime = Runtime.find_by_describe(params[:describe])
      @runtime.destroy
      render json: @runtime
    else
      @runtime = Runtime.find_by_describe(params[:describe])
      jsonpath = xtoy(params[:jsonpath])
      @runtimenew = JsonPath.for(@runtime.as_json).delete(jsonpath).to_hash
      @runtime.update(@runtimenew)
      render json: @runtime
    end
  end

end
