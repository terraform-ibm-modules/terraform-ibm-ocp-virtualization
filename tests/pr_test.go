// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"bytes"
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
	"testing"
	"time"

	"github.com/IBM/go-sdk-core/v5/core"
	"github.com/google/uuid"
	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testaddons"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const quickStartTerraformDir = "solutions/quickstart"
const fullyConfigurableTerraformDir = "solutions/fully-configurable"

var excludeDirs = []string{}
var includeFiletypes = []string{
	".md",
	".sh",
}

// Define a struct with fields that match the structure of the YAML data
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

var (
	sharedInfoSvc      *cloudinfo.CloudInfoService
	permanentResources map[string]interface{}
)

func createContainersApikey(t *testing.T, region string, rg string) {

	err := os.Setenv("IBMCLOUD_API_KEY", validateEnvVariable(t, "TF_VAR_ibmcloud_api_key"))
	require.NoError(t, err, "Failed to set IBMCLOUD_API_KEY environment variable")
	scriptPath := "../common-dev-assets/scripts/iks-api-key-reset/reset_iks_api_key.sh"
	cmd := exec.Command("bash", scriptPath, region, rg)
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	// Execute the command
	if err := cmd.Run(); err != nil {
		log.Fatalf("Failed to execute script: %v\nStderr: %s", err, stderr.String())
	}
	// Print script output
	fmt.Println(stdout.String())
}

// TestMain will be run before any parallel tests, used to set up a shared InfoService object to track region usage
// for multiple tests
func TestMain(m *testing.M) {
	sharedInfoSvc, _ = cloudinfo.NewCloudInfoServiceFromEnv("TF_VAR_ibmcloud_api_key", cloudinfo.CloudInfoServiceOptions{})

	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(m.Run())
}

/*******************************************************************
* TESTS FOR THE TERRAFORM BASED QUICKSTART DEPLOYABLE ARCHITECTURE *
********************************************************************/
func TestRunQuickstartDASchematics(t *testing.T) {
	t.Parallel()

	tarIncludePatterns, recurseErr := testhelper.GetTarIncludeDirsWithDefaults("..", excludeDirs, includeFiletypes)
	// if error producing tar patterns (very unexpected) fail test immediately
	require.NoError(t, recurseErr, "Schematic Test had unexpected error traversing directory tree")

	// Set up a schematics test
	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:            t,
		TarIncludePatterns: tarIncludePatterns,
		TemplateFolder:     quickStartTerraformDir,
		// This is the resource group that the workspace will be created in
		ResourceGroup:          resourceGroup,
		Prefix:                 "virt-qs",
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 180,
	})

	// Pass required variables
	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		// use options.Prefix here to generate a unique prefix every time so resource group name is unique for every test
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "existing_resource_group_name", Value: resourceGroup, DataType: "string"},
		{Name: "machine_type", Value: "bx2.4x16", DataType: "string"},
		{Name: "openshift_entitlement", Value: "cloud_pak", DataType: "string"},
	}

	// Temp workaround for https://github.com/terraform-ibm-modules/terraform-ibm-base-ocp-vpc?tab=readme-ov-file#the-specified-api-key-could-not-be-found
	createContainersApikey(t, options.Region, options.ResourceGroup)

	err := options.RunSchematicTest()
	assert.NoError(t, err, "Schematic Test had unexpected error")
}

func TestRunQuickstartDAUpgrade(t *testing.T) {
	t.Parallel()

	tarIncludePatterns, recurseErr := testhelper.GetTarIncludeDirsWithDefaults("..", excludeDirs, includeFiletypes)
	// if error producing tar patterns (very unexpected) fail test immediately
	require.NoError(t, recurseErr, "Schematic Test had unexpected error traversing directory tree")

	// Set up a schematics test
	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:            t,
		TarIncludePatterns: tarIncludePatterns,
		TemplateFolder:     quickStartTerraformDir,
		// This is the resource group that the workspace will be created in
		ResourceGroup:          resourceGroup,
		Prefix:                 "virt-qs-upg",
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 180,
	})

	// Pass required variables
	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		// use options.Prefix here to generate a unique prefix every time so resource group name is unique for every test
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "existing_resource_group_name", Value: resourceGroup, DataType: "string"},
		{Name: "machine_type", Value: "bx2.4x16", DataType: "string"},
		{Name: "openshift_entitlement", Value: "cloud_pak", DataType: "string"},
	}

	err := options.RunSchematicUpgradeTest()
	assert.NoError(t, err, "Schematic Test had unexpected error")
}

func validateEnvVariable(t *testing.T, varName string) string {
	val, present := os.LookupEnv(varName)
	require.True(t, present, "%s environment variable not set", varName)
	require.NotEqual(t, "", val, "%s environment variable is empty", varName)
	return val
}

func generateUniqueResourceGroupName(baseName string) string {
	id := uuid.New().String()[:8]
	return fmt.Sprintf("%s-%s", baseName, id)
}

func setupTerraform(t *testing.T, prefix, realTerraformDir string) *terraform.Options {
	tempTerraformDir, err := files.CopyTerraformFolderToTemp(realTerraformDir, prefix)
	require.NoError(t, err, "Failed to create temporary Terraform folder")
	apiKey := validateEnvVariable(t, "TF_VAR_ibmcloud_api_key") // pragma: allowlist secret
	region, err := testhelper.GetBestVpcRegion(apiKey, "../common-dev-assets/common-go-assets/cloudinfo-region-vpc-gen2-prefs.yaml", "eu-de")
	require.NoError(t, err, "Failed to get best VPC region")

	uniqueResourceGroup := generateUniqueResourceGroupName(prefix)

	existingTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: tempTerraformDir,
		Vars: map[string]interface{}{
			"prefix":         prefix,
			"region":         region,
			"resource_group": uniqueResourceGroup,
		},
		// Set Upgrade to true to ensure latest version of providers and modules are used by terratest.
		// This is the same as setting the -upgrade=true flag with terraform.
		Upgrade: true,
	})

	err = sharedInfoSvc.WithNewResourceGroup(uniqueResourceGroup, func() error {
		// Temp workaround for https://github.com/terraform-ibm-modules/terraform-ibm-base-ocp-vpc?tab=readme-ov-file#the-specified-api-key-could-not-be-found
		createContainersApikey(t, region, uniqueResourceGroup)
		time.Sleep(5 * time.Second)
		terraform.WorkspaceSelectOrNew(t, existingTerraformOptions, prefix)
		_, err := terraform.InitAndApplyE(t, existingTerraformOptions)
		return err
	})
	require.NoError(t, err, "Failed to initialize and apply Terraform")
	return existingTerraformOptions
}

func cleanupTerraform(t *testing.T, options *terraform.Options, prefix string) {
	if t.Failed() && strings.ToLower(os.Getenv("DO_NOT_DESTROY_ON_FAILURE")) == "true" {
		fmt.Println("Terratest failed. Debug the test and delete resources manually.")
		return
	}
	logger.Log(t, "START: Destroy (existing resources)")
	terraform.Destroy(t, options)
	terraform.WorkspaceDelete(t, options, prefix)
	logger.Log(t, "END: Destroy (existing resources)")
}

func TestRunFullyConfigurableInSchematics(t *testing.T) {
	t.Parallel()

	tarIncludePatterns, recurseErr := testhelper.GetTarIncludeDirsWithDefaults("..", excludeDirs, includeFiletypes)
	// if error producing tar patterns (very unexpected) fail test immediately
	require.NoError(t, recurseErr, "Schematic Test had unexpected error traversing directory tree")

	// Provision resources first
	prefix := fmt.Sprintf("ocp-vi-%s", strings.ToLower(random.UniqueId()))
	existingTerraformOptions := setupTerraform(t, prefix, "./resources")

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:               t,
		Prefix:                "ocp-fc",
		TarIncludePatterns:    tarIncludePatterns,
		TemplateFolder:        fullyConfigurableTerraformDir,
		Tags:                  []string{"test-schematic"},
		DeleteWorkspaceOnFail: false,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "cluster_id", Value: terraform.Output(t, existingTerraformOptions, "workload_cluster_id"), DataType: "string"},
		{Name: "cluster_resource_group_id", Value: terraform.Output(t, existingTerraformOptions, "cluster_resource_group_id"), DataType: "string"},
	}
	require.NoError(t, options.RunSchematicTest(), "This should not have errored")
	cleanupTerraform(t, existingTerraformOptions, prefix)
}

// Upgrade Test does not require KMS encryption
func TestRunUpgradeFullyConfigurable(t *testing.T) {
	t.Parallel()

	tarIncludePatterns, recurseErr := testhelper.GetTarIncludeDirsWithDefaults("..", excludeDirs, includeFiletypes)
	// if error producing tar patterns (very unexpected) fail test immediately
	require.NoError(t, recurseErr, "Schematic Test had unexpected error traversing directory tree")

	// Provision existing resources first
	prefix := fmt.Sprintf("ocp-existing-%s", strings.ToLower(random.UniqueId()))
	skip, err := testhelper.ShouldSkipUpgradeTest(t)
	if err != nil {
		t.Fatal(err)
	}
	if !skip {
		existingTerraformOptions := setupTerraform(t, prefix, "./resources")

		options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
			Testing:               t,
			Prefix:                "fc-upg",
			TarIncludePatterns:    tarIncludePatterns,
			TemplateFolder:        fullyConfigurableTerraformDir,
			Tags:                  []string{"test-schematic"},
			DeleteWorkspaceOnFail: false,
		})

		options.TerraformVars = []testschematic.TestSchematicTerraformVar{
			{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
			{Name: "cluster_id", Value: terraform.Output(t, existingTerraformOptions, "workload_cluster_id"), DataType: "string"},
			{Name: "cluster_resource_group_id", Value: terraform.Output(t, existingTerraformOptions, "cluster_resource_group_id"), DataType: "string"},
		}

		require.NoError(t, options.RunSchematicUpgradeTest(), "This should not have errored")
		cleanupTerraform(t, existingTerraformOptions, prefix)
	}
}

func TestAddonConfigurations(t *testing.T) {
	t.Parallel()

	options := testaddons.TestAddonsOptionsDefault(&testaddons.TestAddonOptions{
		Testing:               t,
		Prefix:                "virt-def",
		ResourceGroup:         resourceGroup,
		OverrideInputMappings: core.BoolPtr(true),
		QuietMode:             false,
	})
	region := "eu-de"

	// Temp workaround for https://github.com/terraform-ibm-modules/terraform-ibm-base-ocp-vpc?tab=readme-ov-file#the-specified-api-key-could-not-be-found
	createContainersApikey(t, region, options.ResourceGroup)

	options.AddonConfig = cloudinfo.NewAddonConfigTerraform(
		options.Prefix,
		"deploy-arch-ibm-ocp-virtualization",
		"fully-configurable",
		map[string]interface{}{
			"region":                       region,
			"secrets_manager_service_plan": "__NULL__",
			"existing_resource_group_name": options.ResourceGroup,
		},
	)

	//	use existing secrets manager instance to help prevent hitting trial instance limit in account
	options.AddonConfig.Dependencies = []cloudinfo.AddonConfig{
		{
			OfferingName:   "deploy-arch-ibm-secrets-manager",
			OfferingFlavor: "fully-configurable",
			Inputs: map[string]interface{}{
				"existing_secrets_manager_crn":         permanentResources["privateOnlySecMgrCRN"],
				"service_plan":                         "__NULL__", // no plan value needed when using existing SM
				"skip_secrets_manager_iam_auth_policy": true,       // since using an existing Secrets Manager instance, attempting to re-create auth policy can cause conflicts if the policy already exists
				"secret_groups":                        []string{}, // passing empty array for secret groups as default value is creating general group and it will cause conflicts as we are using an existing SM
			},
		},
		// // Disable target / route creation to help prevent hitting quota in account
		{
			OfferingName:   "deploy-arch-ibm-cloud-monitoring",
			OfferingFlavor: "fully-configurable",
			Inputs: map[string]interface{}{
				"enable_metrics_routing_to_cloud_monitoring": false,
			},
		},
		{
			OfferingName:   "deploy-arch-ibm-activity-tracker",
			OfferingFlavor: "fully-configurable",
			Inputs: map[string]interface{}{
				"enable_activity_tracker_event_routing_to_cloud_logs": false,
			},
		},
	}

	err := options.RunAddonTest()
	require.NoError(t, err)
}
