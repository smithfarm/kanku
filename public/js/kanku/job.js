function save_settings(job_name) {
  var test = $("#"+job_name+" input");
  var count  = -1;
  var data   = [];
  $.each(test, function(iter, elem) {
    if (elem.name === "use_module") {
      count++;
      data[count]={};
    } else {
      if (elem.type === 'text') {
	data[count][elem.name] = elem.value;
      }
      if (elem.type === 'checkbox') {
	data[count][elem.name] = elem.checked;
      }
    }
  });
  var cookie = restore_settings();
  cookie[job_name] = data;
  Cookies.set("kanku_job", JSON.stringify(cookie));
  return data;
}

function restore_settings() {
  var obj = Cookies.get("kanku_job");
  if (!obj) { obj = "{}" }
  return JSON.parse(obj);
}


Vue.component('text-input',{
  props: ['gui_config'],
  data: function() {
    return { user_name : user_name }
  },
  computed: {
    needsPrefix: function() {
      if (this.gui_config.param == 'domain_name' && active_roles.User && ! active_roles.Admin) {
        return true
      }
    }
  },
  template: '<div class="form-group">'
    + ' <label>{{ gui_config.label }} :<strong v-if="needsPrefix"> (Will be prefixed by \'{{ user_name }}-\')</strong></label>'
    + ' <input  class="form-control"'
    + '        type=text'
    + '        :name="gui_config.param"'
    + '        :value="gui_config.default"'
    + ' >'
    + '</div>'
});

Vue.component('checkbox-input',{
  props: ['gui_config'],
  template: '<div class="form-group">'
    + ' <label>{{ gui_config.label }} :</label>'
    + ' <input type=checkbox :name="gui_config.param" value="1" :checked="gui_config.default">'
    + '</div>'
});

Vue.component('task-card',{
  props: ['task'],
  data: function() {
    return {
      showTaskList: 0
    }
  },
  template: '<div class=task-card>'
    + '   <h4><span class="badge badge-secondary" style="display:block;" v-on:click="showValues()">{{ task.use_module }}</span></h4>'
    + '     <input type=hidden name="use_module" :value="task.use_module">'
    + '   <div v-for="c in task.gui_config">'
    + '    <text-input v-if="c.type == \'text\'" v-bind:gui_config=c></text-input>'
    + '    <checkbox-input v-if="c.type == \'checkbox\'" v-bind:gui_config=c></checkbox-input>'
    + '   </div>'
    + '</div>'
});

Vue.component('job-card',{
  props: ['job'],
  data: function() {
    return {
      showTaskList: 0
    }
  },
  methods: {
    toggleTaskList: function() {
      this.showTaskList = !this.showTaskList;
    },
    restoreDefaults: function() {
      $.each(this.job.sub_tasks, function(iter, subtask) {
        $.each(subtask.gui_config, function(iter2, gc) {
          gc.default = gc.original_default;
        });
      });
      save_settings(this.job.job_name);
    },
    triggerJob: function() {
      var url    = uri_base + "/rest/job/trigger/"+this.job.job_name+".json";
      var data = save_settings(this.job.job_name);
      axios.post(url, data).then(function(response) {
        show_messagebox(response.data.state, response.data.msg);
      });
    }
  },
  template: '<div class="card" style="margin-bottom:5px;">'
    + ' <div class="card-header" v-on:click=toggleTaskList()>'
    + '  <span class="badge badge-secondary">{{ job.job_name }}</span>'
    + ' </div>'
    + ' <form :id="job.job_name">'
    + ' <div class="card-body" v-show="showTaskList">'
    + '  <div class=job_task_list>'
    + '   <div'
    + '    v-for="task in job.sub_tasks"'
    + '    v-bind:task="task"'
    + '    >'
    + '     <task-card v-bind:task="task"></task-card>'
    + '   </div>'
    + '  </div>'
    + ' </div>'
    + ' <div class="card-footer">'
    + '  <div class="btn btn-success btn-sm" v-on:click="triggerJob()">'
    + '   Trigger Job'
    + '  </div>'
    + '  <div class="btn btn-primary btn-sm" v-on:click="restoreDefaults()">'
    + '   Restore Defaults'
    + '  </div>'
    + ' </div>'
    + ' </form>'
    + '</div>'
});

var vm = new Vue({
  el: '#vue_app',
  data: {
    jobs: [],
    original_jobs: []
  },
  methods: {
    updatePage: function() {
      var url    = uri_base + "/rest/gui_config/job.json";
      var self   = this;
      var params = new URLSearchParams();
      axios.get(url, { params: params }).then(function(response) {
	self.jobs = response.data.config;
        self.original_jobs = Object.assign(self.jobs, self.original_jobs);
        var cookie = restore_settings();
        self.jobs.forEach(function(job) {
          $.each(cookie[job.job_name], function(iter, cookie_config) {
            $.each(Object.keys(cookie_config), function(iter2, key) {
               $.each(job.sub_tasks[iter].gui_config, function(iter3, config_element) {
                 if (config_element.param === key) {
                   config_element.original_default = config_element.default;
                   config_element.default = cookie_config[key];
                 }
               });
            });
          });
        });
        $('#spinner').hide();
      });
    }
  },
  mounted: function() {
      this.updatePage();
  }
});
