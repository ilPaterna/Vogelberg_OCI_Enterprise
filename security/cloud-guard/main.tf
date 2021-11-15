# ---------------------------------------------------------------------------------------------------------------------
# Random IDs to prevent naming collision with tenancy level resources
# ---------------------------------------------------------------------------------------------------------------------
resource "random_id" "policy_name" {
  byte_length = 8
}

resource "random_id" "target_name" {
  byte_length = 8
}

resource "oci_cloud_guard_cloud_guard_configuration" "tenancy_cloud_guard_configuration" {
  compartment_id   = var.tenancy_ocid
  reporting_region = var.region
  status           = var.cloud_guard_configuration_status
}

# ---------------------------------------------------------------------------------------------------------------------
# Cloud Guard policies
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_identity_policy" "cloud_guard_policy" {
  compartment_id = var.tenancy_ocid
  description    = "OCI Landing Zone Cloud Guard Policy"
  name           = "${var.cloud_guard_policy_name}-${random_id.policy_name.id}"

  freeform_tags = {
    "Description" = "Cloud guard activity detector recipe"
    "CostCenter"  = var.tag_cost_center,
    "GeoLocation" = var.tag_geo_location
  }

  statements = [
    "Allow service cloudguard to read keys in tenancy",
    "Allow service cloudguard to read compartments in tenancy",
    "Allow service cloudguard to read compute-management-family in tenancy",
    "Allow service cloudguard to read instance-family in tenancy",
    "Allow service cloudguard to read virtual-network-family in tenancy",
    "Allow service cloudguard to read volume-family in tenancy",
    "Allow service cloudguard to read tenancies in tenancy",
    "Allow service cloudguard to read audit-events in tenancy",
    "Allow service cloudguard to read vaults in tenancy",
    "Allow service cloudguard to read object-family in tenancy",
    "Allow service cloudguard to read load-balancers in tenancy",
    "Allow service cloudguard to read object-family in tenancy",
    "Allow service cloudguard to read groups in tenancy",
    "Allow service cloudguard to read dynamic-groups in tenancy",
    "Allow service cloudguard to read users in tenancy",
    "Allow service cloudguard to read database-family in tenancy",
    "Allow service cloudguard to read authentication-policies in tenancy",
    "Allow service cloudguard to read policies in tenancy"
  ]

  depends_on = [oci_cloud_guard_cloud_guard_configuration.tenancy_cloud_guard_configuration]
}

# ---------------------------------------------------------------------------------------------------------------------
# Cloud Guard target
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_cloud_guard_target" "cloud_guard_target" {
  #Required
  compartment_id       = var.parent_compartment_ocid
  display_name         = "${var.cloud_guard_target_name}-${random_id.target_name.id}"
  target_resource_id   = var.parent_compartment_ocid
  target_resource_type = var.target_resource_type
  description          = var.target_description

  freeform_tags = {
    "Description" = "Cloud guard target"
    "CostCenter"  = var.tag_cost_center,
    "GeoLocation" = var.tag_geo_location
  }

  target_detector_recipes {
    detector_recipe_id = data.oci_cloud_guard_detector_recipes.configuration_detector_recipe.detector_recipe_collection.0.items.0.id
  }
  target_detector_recipes {
    detector_recipe_id = data.oci_cloud_guard_detector_recipes.activity_detector_recipe.detector_recipe_collection.0.items.0.id
  }
}