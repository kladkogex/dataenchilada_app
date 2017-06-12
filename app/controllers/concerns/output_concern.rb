module OutputConcern
  extend ActiveSupport::Concern

  def get_outputs
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
