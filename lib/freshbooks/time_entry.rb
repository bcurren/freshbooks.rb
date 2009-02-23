module FreshBooks
  TimeEntry = BaseObject.new(:time_entry_id, :project_id, :task_id, :hours,
  :notes, :date)
  
  class TimeEntry
    TYPE_MAPPINGS = { 'time_entry_id' => Fixnum, 'project_id' => Fixnum,
      'task_id' => Fixnum, 'hours' => Float }
    
    def create
      resp = FreshBooks::call_api('time_entry.create', 'time_entry' => self)
      if resp.success?
        self.time_entry_id = resp.elements[1].text.to_i
      end

      resp.success? ? self.time_entry_id : nil
    end

    def update
      resp = FreshBooks::call_api('time_entry.update', 'time_entry' => self)

      resp.success?
    end

    def self.get(time_entry_id)
      resp = FreshBooks::call_api('time_entry.get', 'time_entry_id' => time_entry_id)

      resp.success? ? self.new_from_xml(resp.elements[1]) : nil
    end

    def delete
      TimeEntry::delete(self.time_entry_id)
    end

    def self.delete(time_entry_id)
      resp = FreshBooks::call_api('time_entry.delete', 'time_entry_id' => time_entry_id)

      resp.success?
    end

    def self.list(options = {})
      resp = FreshBooks::call_api('time_entry.list', options)

      return nil unless resp.success?
      self.build_list_with_pagination(resp)
    end
  end
end
