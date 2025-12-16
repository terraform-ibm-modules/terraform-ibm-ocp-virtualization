// Tests in this file are NOT run in the PR pipeline. They are run in the continuous testing pipeline along with the ones in pr_test.go
package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

const basicExampleDir = "examples/basic"
const ocpVersion1 = "4.17"

func setupOptions(t *testing.T, prefix string, terraformDir string, ocpVersion string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:          t,
		TerraformDir:     terraformDir,
		Prefix:           prefix,
		ResourceGroup:    resourceGroup,
		CloudInfoService: sharedInfoSvc,
		TerraformVars: map[string]interface{}{
			"ocp_version":     ocpVersion,
			"access_tags":     permanentResources["accessTags"],
			"ocp_entitlement": "cloud_pak",
		},
	})

	return options
}

func TestRunBasicExample(t *testing.T) {
	// t.Parallel()
	t.Skip()

	options := setupOptions(t, "ocp-virt", basicExampleDir, ocpVersion1)

	output, err := options.RunTestConsistency()

	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}
