class WeeklyMonitoringAccessPointsController < ApplicationController
  before_filter :load_wisp
  before_filter :load_access_point
  
  access_control :subject_method => :current_operator do
    default :deny

    allow :admin
    allow :wisp_admin, :of => :wisp, :to => [:show]
    allow :wisp_operator, :of => :wisp, :to => [:show]
    allow :access_point_admin, :of => :access_point, :to => [:show]
    allow :access_point_operator, :of => :access_point, :to => [:show]
  end

  def load_wisp
    @wisp = Wisp.find(params[:wisp_id])
  end
  
  def load_access_point
    @access_point = @wisp.access_points.find(params[:access_point_id])
  end

  def show
    # TO_DO: accept time frame for graph
    @graph_data = WeeklyMonitoringAccessPoint.find_all_by_access_point_id(@access_point.id, :order => 'date',  :conditions => ["date > ?", Date.today-7 ]  )

    respond_to do |format|
      unless @graph_data.nil?
        format.xml # show.xml.erb
      else
        format.xml { render :text => '' }
      end
    end
  end

end
