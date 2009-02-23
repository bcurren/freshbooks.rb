module FreshBooks
  Task = BaseObject.new(:task_id, :name, :billable, :rate, :description)
  
  class Task
    TYPE_MAPPINGS = { 'task_id' => Fixnum, 'rate' => Float }
    
    def create
      resp = FreshBooks::call_api('task.create', 'task' => self)
      if resp.success?
        self.task_id = resp.elements[1].text.to_i
      end

      resp.success? ? self.task_id : nil
    end

    def update
      resp = FreshBooks::call_api('task.update', 'task' => self)

      resp.success?
    end

    def self.get(task_id)
      resp = FreshBooks::call_api('task.get', 'task_id' => task_id)

      resp.success? ? self.new_from_xml(resp.elements[1]) : nil
    end

    def delete
      Task::delete(self.task_id)
    end

    def self.delete(task_id)
      resp = FreshBooks::call_api('task.delete', 'task_id' => task_id)

      resp.success?
    end

    def self.list(options = {})
      resp = FreshBooks::call_api('task.list', options)

      return nil unless resp.success?
      self.build_list_with_pagination(resp)
    end
  end
end
