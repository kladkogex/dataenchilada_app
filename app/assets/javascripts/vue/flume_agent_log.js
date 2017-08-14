(function(){
  "use strict";

  $(function(){
    if($('#flume-agent-log').length === 0) return;

    new Vue({
      el: "#flume-agent-log",
      paramAttributes: ["logUrl", "logType", "initialAutoReload"],
      data: {
        "autoFetch": false,
        "logs": [],
        "limit": 30,
        "processing": false
      },

      compiled: function(){
        this.fetchLogs();

        var self = this;
        var timer;
        this.$watch("autoFetch", function(newValue){
          if(newValue === true) {
            timer = setInterval(function(){
              self.fetchLogs();
              var $log = $(".log", self.$el);
              $log.scrollTop($log.innerHeight());
            }, 15000);
          } else {
            clearInterval(timer);
          }
        });
        if(this.initialAutoReload) {
          this.autoFetch = true;
        }
      },

      computed: {
        isPresentedLogs: function(){
          return this.logs.length > 0;
        }
      },

      methods: {
        fetchLogs: function() {
          if(this.processing) return;
          this.processing = true;
          var self = this;

          console.log(self);

          new Promise(function(resolve, reject) {
            $.getJSON('log_tail?limit='+ self.limit+'&type='+self.logType, resolve).fail(reject);
          }).then(function(logs){
            self.logs = logs;
            setTimeout(function(){
              self.processing = false;
            }, 256); // delay to reduce flicking loading icon
          })["catch"](function(error){
              //self.logs = error.responseText;
            self.processing = false;
          });
        }
      }
    });
  });
})();

