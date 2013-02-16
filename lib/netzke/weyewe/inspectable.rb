module Netzke
  module Weyewe
    module Inspectable
      extend ActiveSupport::Concern

      included do |base|
        include Netzke::Basepack::ActionColumn

        column :inspect do |c|
          c.type = :action
          c.actions = [{name: :inspect, icon: :arrow_right}]
          c.width = 20
          c.text = ""
          # c.show_path = "/record_name"
          
        end

        js_configure do |c|
          c.on_inspect = <<-JS
            function(record){
//              <a href="http://www.starfall.com/" target="_blank">Starfall</a>
       //       var workspace = Ext.ComponentManager.get('application__workspace');
      //        workspace.loadInTab("#{name.sub("Grid", "Inspector")}", {config: {record_id: record.get('id')}, newTab: true});
             console.log("the play_will is " + this.inspect_url + '/' + record.get("id"));
             console.log( this );
             console.dir(this );
              window.open("http://www.kompas.com", "_blank");
            }
          JS
        end
      end
    end
  end
end
