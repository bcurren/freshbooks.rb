module FreshBooks
  Project = BaseObject.new(:project_id, :client_id, :name, :bill_method, :rate,
  :description, :tasks)
  
  class Project
    TYPE_MAPPINGS = { 'project_id' => Fixnum, 'client_id' => Fixnum,
      'rate' => Float, 'tasks' => Array
    }
    
    def initialize
      super
      self.tasks ||= []
    end

    def create
      resp = FreshBooks::call_api('project.create', 'project' => self)
      if resp.success?
        self.project_id = resp.elements[1].text.to_i
      end

      resp.success? ? self.project_id : nil
    end

    def update
      resp = FreshBooks::call_api('project.update', 'project' => self)

      resp.success?
    end

    def self.get(project_id)
      resp = FreshBooks::call_api('project.get', 'project_id' => project_id)

      resp.success? ? self.new_from_xml(resp.elements[1]) : nil
    end

    def delete
      Project::delete(self.project_id)
    end

    def self.delete(project_id)
      resp = FreshBooks::call_api('project.delete', 'project_id' => project_id)

      resp.success?
    end

    def self.list(options = {})
      resp = FreshBooks::call_api('project.list', options)

      return nil unless resp.success?
      self.build_list_with_pagination(resp)
    end
  end
end