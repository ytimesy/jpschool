module Admin
  class UsersController < ApplicationController
    def index
      @users = [
        { login_id: 'A0001', display_name: 'Nguyen Van A', locale: 'vi', department: '工場1', job_type: '製造', status: '有効', last_login: '2026-09-01 08:12', last_learning: '2026-09-01 08:28' },
        { login_id: 'A0002', display_name: 'Maria Santos', locale: 'en', department: '物流', job_type: '仕分け', status: '有効', last_login: '2026-08-31 17:45', last_learning: '2026-08-31 18:02' },
        { login_id: 'A0003', display_name: 'Tran Binh', locale: 'vi', department: '工場2', job_type: '検品', status: '停止', last_login: '2026-08-20 07:50', last_learning: '2026-08-20 08:10' }
      ]
    end

    def show
      @user = { login_id: params[:id], display_name: 'Nguyen Van A', locale: 'vi', department: '工場1', job_type: '製造', status: '有効' }
    end
  end
end
