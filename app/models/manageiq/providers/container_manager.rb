module ManageIQ::Providers
  class ContainerManager < BaseManager
    include AvailabilityMixin
    include HasMonitoringManagerMixin
    include SupportsFeatureMixin

    has_many :container_nodes, :foreign_key => :ems_id, :dependent => :destroy
    has_many :container_groups, -> { active }, :foreign_key => :ems_id
    has_many :container_services, :foreign_key => :ems_id, :dependent => :destroy
    has_many :container_replicators, :foreign_key => :ems_id, :dependent => :destroy
    has_many :containers, -> { active }, :foreign_key => :ems_id
    has_many :container_definitions, -> { active }, :foreign_key => :ems_id
    has_many :container_projects, -> { active }, :foreign_key => :ems_id
    has_many :container_quotas, :foreign_key => :ems_id, :dependent => :destroy
    has_many :container_limits, :foreign_key => :ems_id, :dependent => :destroy
    has_many :container_image_registries, :foreign_key => :ems_id, :dependent => :destroy
    has_many :container_images, -> { active }, :foreign_key => :ems_id
    has_many :persistent_volumes, :as => :parent, :dependent => :destroy
    has_many :persistent_volume_claims, :foreign_key => :ems_id, :dependent => :destroy
    has_many :container_component_statuses, :foreign_key => :ems_id, :dependent => :destroy
    has_many :container_builds, :foreign_key => :ems_id, :dependent => :destroy
    has_many :container_build_pods, :foreign_key => :ems_id, :dependent => :destroy
    has_many :container_templates, :foreign_key => :ems_id, :dependent => :destroy
    has_one :container_deployment, :foreign_key => :deployed_ems_id, :inverse_of => :deployed_ems

    # Shortcuts to chained joins, mostly used by inventory refresh.
    has_many :computer_systems, :through => :container_nodes
    has_many :computer_system_hardwares, :through => :computer_systems, :source => :hardware
    has_many :computer_system_operating_systems, :through => :computer_systems, :source => :operating_system
    has_many :container_volumes, :through => :container_groups
    has_many :container_port_configs, :through => :container_definitions
    has_many :container_env_vars, :through => :container_definitions
    has_many :security_contexts, :through => :container_definitions
    has_many :container_service_port_configs, :through => :container_services
    has_many :container_routes, :through => :container_services
    has_many :container_quota_items, :through => :container_quotas
    has_many :container_limit_items, :through => :container_limits
    has_many :container_template_parameters, :through => :container_templates

    # Archived and active entities to destroy when the container manager is deleted
    has_many :all_containers, :foreign_key => :ems_id, :dependent => :destroy, :class_name => "Container"
    has_many :all_container_groups, :foreign_key => :ems_id, :dependent => :destroy, :class_name => "ContainerGroup"
    has_many :all_container_projects, :foreign_key => :ems_id, :dependent => :destroy, :class_name => "ContainerProject"
    has_many :all_container_images, :foreign_key => :ems_id, :dependent => :destroy, :class_name => "ContainerImage"
    has_many :all_container_definitions, :foreign_key => :ems_id, :dependent => :destroy, :class_name => "ContainerDefinition"


    virtual_column :port_show, :type => :string

    supports :external_logging do
      unless respond_to?(:external_logging_route_name)
        unsupported_reason_add(:external_logging, _('This provider type does not support external_logging'))
      end
    end

    # required by aggregate_hardware
    alias :all_computer_systems :computer_systems
    alias :all_computer_system_ids :computer_system_ids

    def aggregate_cpu_total_cores(targets = nil)
      aggregate_hardware(:computer_systems, :cpu_total_cores, targets)
    end

    def aggregate_memory(targets = nil)
      aggregate_hardware(:computer_systems, :memory_mb, targets)
    end

    class << model_name
      define_method(:route_key) { "ems_containers" }
      define_method(:singular_route_key) { "ems_container" }
    end

    # enables overide of ChartsLayoutService#find_chart_path
    def chart_layout_path
      "ManageIQ_Providers_ContainerManager"
    end

    def validate_performance
      {:available => true, :message => nil}
    end

    def validate_ad_hoc_metrics
      {:available => true, :message => nil}
    end

    def validate_authentication_status
      {:available => true, :message => nil}
    end

    def port_show
      port.to_s
    end
  end
end
