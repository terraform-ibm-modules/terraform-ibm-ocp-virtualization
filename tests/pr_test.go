// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"log"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const quickStartTerraformDir = "solutions/quickstart"

// Define a struct with fields that match the structure of the YAML data
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

var (
	sharedInfoSvc      *cloudinfo.CloudInfoService
	permanentResources map[string]interface{}
)

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

	// Set up a schematics test
	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:            t,
		TarIncludePatterns: []string{"*.tf", quickStartTerraformDir + "/*.*", quickStartTerraformDir + "/scripts/*.*", "kubeconfig/README.md"},
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
	}

	err := options.RunSchematicTest()
	assert.NoError(t, err, "Schematic Test had unexpected error")
}

func TestRunQuickstartDAUpgrade(t *testing.T) {
	t.Parallel()

	// Set up upgrade test
	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: quickStartTerraformDir,
		Prefix:       "virt-qs-upg",
	})

	// Pass required variables (NOTE: ibmcloud_api_key is passed directly in test as TF_VAR so no need to include here)
	options.TerraformVars = map[string]interface{}{
		"prefix":                       options.Prefix,
		"existing_resource_group_name": resourceGroup,
		"machine_type":                 "bx2.4x16",
	}

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}
