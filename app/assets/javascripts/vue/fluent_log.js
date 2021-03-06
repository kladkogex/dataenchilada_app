(function(){
  "use strict";

  $(function(){
    if($('#fluent-log').length === 0) return;

    new Vue({
      el: "#fluent-log",
      paramAttributes: ["logUrl", "initialAutoReload"],
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
          new Promise(function(resolve, reject) {
            $.getJSON('log_tail?limit='+ self.limit, resolve).fail(reject);
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

