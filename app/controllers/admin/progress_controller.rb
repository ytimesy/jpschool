module Admin
  class ProgressController < ApplicationController
    def index
      @rows = [
        { name: 'Nguyen Van A', department: '工場1', completed: 5, passed: 4, average: 86, last_learning: '2026-09-01 08:28' },
        { name: 'Maria Santos', department: '物流', completed: 3, passed: 2, average: 78, last_learning: '2026-08-31 18:02' },
        { name: 'Tran Binh', department: '工場2', completed: 1, passed: 1, average: 90, last_learning: '2026-08-20 08:10' }
      ]
    end
  end
end
