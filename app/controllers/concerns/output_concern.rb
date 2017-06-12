module OutputConcern
  extend ActiveSupport::Concern

  def get_outputs
    outputs = []
    blabla = output_params
    blabla['outputs'].each do |key, data|
      if data['enabled'] == 'true'
        output = Output::OUTPUT_TYPES[key].constantize.new
        output.details = Output::OUTPUT_TYPES[key].constantize::DETAILS_CLASS.new(Output::OUTPUT_TYPES[key].constantize.initial_params)
        output.details.send("#{Output::STREAM_FIELD_NAMES[key]}=", data[Output::STREAM_FIELD_NAMES[key]])
        outputs << output
      end
    end
    outputs
  end

  def get_outputs_for_local
    outputs = []
    blabla = output_params
    blabla.each do |key, data|
      if data['enabled'] == 'true'
        output = Output::OUTPUT_TYPES[key].constantize.new
        output.details = Output::OUTPUT_TYPES[key].constantize::DETAILS_CLASS.new(Output::OUTPUT_TYPES[key].constantize.initial_params)
        output.details.send("#{Output::STREAM_FIELD_NAMES[key]}=", data[Output::STREAM_FIELD_NAMES[key]])
        outputs << output
      end
    end
    outputs
  end

  private

  def output_params
    #params.require('agent').require('outputs')
    params.require(:agent).permit!
  end

end

=begin
{"agent"=>{"title"=>"qweeqerwererer", "tag"=>"wererewerwwerwer",
           "source"=>{
                "consumer_key"=>"a530R2VCibX8qDE1e19EIvm18", "consumer_secret"=>"9QmK9w3ZaAEJGJxmrYd0dE5EhxFdTHTsr57WXHetE21M0VzPv8",
                "access_token"=>"454451418-hGagC8lLAwVPfXOLtfNlrPgUnMGuMD7JYvNdyluH",
                "access_token_secret"=>"fqReoxNwIZwCi5v9nd0lOszWssDCHMnO0mpdpTUphh4DH", "keyword"=>"nasa",
                "timeline"=>"tracking", "follow_ids"=>"", "locations"=>"", "lang"=>"en",
                "output_format"=>"simple"},
           "outputs"=>{
               "kafka"=>{"enabled"=>"false", "default_topic"=>"wererewerwwerwer"},
               "elasticsearch"=>{"enabled"=>"true", "index_name"=>"wererewerwwerwer"},
               "cassandra"=>{"enabled"=>"false", "keyspace"=>"wererewerwwerwer"},
               "webhdfs"=>{"enabled"=>"false", "path"=>"wererewerwwerwer"},
               "forward"=>{"enabled"=>"false", "server"=>"wererewerwwerwer"},
               "file"=>{"enabled"=>"false", "path"=>"wererewerwwerwer"},
               "kudu"=>{"enabled"=>"false", "table_name"=>"wererewerwwerwer"}
           }
      }
}
=end