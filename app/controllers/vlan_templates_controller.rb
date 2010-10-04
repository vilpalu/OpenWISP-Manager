class VlanTemplatesController < ApplicationController
  layout nil

  before_filter :load_wisp
  before_filter :load_access_point_template
  
  access_control :subject_method => :current_operator do
    default :deny

    allow :admin
    allow :wisp_admin, :of => :wisp, :to => [ :index, :new, :create, :destroy]
    allow :wisp_operator, :of => :wisp, :to => [ :index, :new, :create, :destroy]
    allow :wisp_viewer, :of => :wisp, :to => [ :index ]
  end

  def load_wisp
    @wisp = Wisp.find(params[:wisp_id])
  end
  
  def load_access_point_template
    @access_point_template = @wisp.access_point_templates.find(params[:access_point_template_id])
  end
  
  def index
    @device_templates = @access_point_template.interface_templates
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def new
    @device_templates = @access_point_template.interface_templates
    @tap_templates = @access_point_template.tap_templates
    @ethernet_templates = @access_point_template.ethernet_templates

    @interface_template_select = @tap_templates.map { |t| [ t.friendly_name, "#{t.id}_tap" ] }
    @interface_template_select.concat(@ethernet_templates.map { |e| [ e.friendly_name, "#{e.id}_ethernet" ] })
    @interface_template_select_selected = []
 
    @vlan_template = VlanTemplate.new()

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
    @tap_templates = @access_point_template.tap_templates
    @ethernet_templates = @access_point_template.ethernet_templates

    @interface_template_select = @tap_templates.map { |t| [ t.friendly_name, "#{t.id}_tap" ] }
    @interface_template_select.concat(@ethernet_templates.map { |e| [ e.friendly_name, "#{e.id}_ethernet" ] })

    unless params[:interface_template_select].nil?
      @idt = params[:interface_template_select].split('_')
      if @idt[1] == 'tap'
        interface_template = @tap_templates.find(@idt[0])
      elsif @idt[1] == 'ethernet'
        interface_template = @ethernet_templates.find(@idt[0])
      end
      @vlan_template = interface_template.vlan_templates.build(params[:vlan_template])
    end

    respond_to do |format|
      if @vlan_template.save
        format.html { 
          redirect_to(wisp_access_point_template_vlan_templates_url(@wisp, @access_point_template)) 
        }
      else
        format.html { render :action => "new" }
      end
    end
    
  end

  def destroy
    @vlan_template = VlanTemplate.find(params[:id])
    @vlan_template.destroy
    
    respond_to do |format|
      format.html { redirect_to(wisp_access_point_template_vlan_templates_url(@wisp, @access_point_template)) }
    end
  end
end
