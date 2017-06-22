class Fluentd
  module Setting
    class InTwitter < Source
      # include ActiveModel::Model
      include Common

      relate_to_details

      KEYS = [
          :consumer_key,
          :consumer_secret,
          :access_token,
          :access_token_secret,
          :timeline,
          :keyword,
          :follow_ids,
          :locations,
          :lang,
          :output_format
      ].freeze
      #
      # attr_accessor(*KEYS)
      #

      # def self.default_tag
      #   'twitter_nasa'
      # end

      def self.initial_params
        {
            timeline: 'tracking',
            keyword: 'nasa',
            follow_ids: '',
            locations: '',
            lang: :en,
            output_format: 'simple',
            consumer_key: 'a530R2VCibX8qDE1e19EIvm18',
            consumer_secret: '9QmK9w3ZaAEJGJxmrYd0dE5EhxFdTHTsr57WXHetE21M0VzPv8',
            access_token: '454451418-hGagC8lLAwVPfXOLtfNlrPgUnMGuMD7JYvNdyluH',
            access_token_secret: 'fqReoxNwIZwCi5v9nd0lOszWssDCHMnO0mpdpTUphh4DH'
        }
      end

      def fields_descriptions
        {
            #consumer_key: '* YOUR_CONSUMER_KEY (required)',
            #consumer_secret: '* YOUR_CONSUMER_SECRET (required)',
            #access_token: '* YOUR_CONSUMER_SECRET (required)',
            #access_token_secret: '* YOUR_CONSUMER_SECRET (required)',
            # tag: '* for example input.twitter.sampling (required)',
            timeline: '* tracking or sampling or location or userstream (required)',
            keyword: 'Comma-separated words to search for.',
            follow_ids: 'Comma-separated ids of users to follow; e.g 4855821694, 11348282',
            locations: 'Bounding boxes: first pair specifies longitude/latitude of southwest corner; e.g. 50.199056, 35.018921, 48.981299, 37.413940',
            #lang: 'ja,en (optional)',
            #output_format: 'nest or flat or simple[default] (optional)'
        }
      end

      def fields_types
        {
            output_format: {type: 'dropdown', values: ['simple', 'nest', 'flat']},
            timeline: {type: 'dropdown', values: ['tracking', 'sampling', 'location', 'userstream']},
            #lang: {type: 'hidden'}
        }
      end

      def fields_titles
        {
            timeline: 'Timeline',
            keyword: 'Keywords',
            follow_ids: 'Follow IDs',
            locations: 'Location',
            lang: 'Language',
            output_format: 'Output format',
            consumer_key: 'Consumer key',
            consumer_secret: 'Consumer secret',
            access_token: 'Access token',
            access_token_secret: 'Access token secret'
        }
      end


      def common_options
        [
            :keyword, :consumer_key, :consumer_secret, :access_token, :access_token_secret
        ]
      end

      def advanced_options
        [
            :timeline, :follow_ids, :locations, :lang, :output_format
        ]
      end

      def plugin_name
        "twitter"
      end
    end
  end
end