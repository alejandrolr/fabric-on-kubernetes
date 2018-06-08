package main

import (
	"bytes"
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	sc "github.com/hyperledger/fabric/protos/peer"
)

type SmartContract struct {
}

// MarketingAuthorization defines a marketing authorization in order to produce a medicine
type MarketingAuthorization struct {
	LaboratoryName string `json:"laboratoryName"`
	Medicine       string `json:"medicine"`
	CreatedDate    string `json:"createdDate"`
	AuthDate       string `json:"authDate"`
	Price          string `json:"price"`
}

type Laboratory struct {
	LaboratoryName string `json:"laboratoryName"`
}

type ARM struct {
	Owner                  string                   `json:"owner"`
	Desc                   string                   `json:"desc"`
	Laboratory             []Laboratory             `json:"laboratory"`
	MarketingAuthorization []MarketingAuthorization `json:"authorizations"`
}

func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	fmt.Printf("SmartContract has been instantiated \n")
	return shim.Success(nil)
}

func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {

	// Retrieve the requested Smart Contract function and arguments
	function, args := APIstub.GetFunctionAndParameters()

	// Route to the appropriate handler function to interact with the ledger appropriately
	/*if function == "createLaboratory" {
		return s.createLaboratory(APIstub, args)
	} else */
	if function == "addARM" {
		return s.addARM(APIstub, args)
	} else if function == "addLaboratory" {
		return s.addLaboratory(APIstub, args)
	} else if function == "queryByMarketingAuthorization" {
		return s.queryByMarketingAuthorization(APIstub, args)
	} else if function == "queryLabsJSON" {
		return s.queryLabsJSON(APIstub, args)
	} else if function == "createMarketingAuthorization" { // LAB function
		return s.createMarketingAuthorization(APIstub, args)
	}

	return shim.Error("Invalid Smart Contract function name.")
}

// ./executeTransaction.sh '{"Args":["addARM", "OWNER1", "PEPITO GRILLO"]}' armcc
func (s *SmartContract) addARM(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	var arm = ARM{
		Owner:                  args[0],
		Desc:                   args[1],
		Laboratory:             nil,
		MarketingAuthorization: nil,
	}

	armAsBytes, _ := json.Marshal(arm)
	APIstub.PutState(args[0], armAsBytes)

	return shim.Success(nil)
}

// ./executeTransaction.sh '{"Args":["addLaboratory", "OWNER1", "BAYER"]}' armcc
func (s *SmartContract) addLaboratory(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	var lab = Laboratory{
		LaboratoryName: args[1],
	}

	armAsBytes, err := APIstub.GetState(args[0])
	if err != nil {
		return shim.Error("Failed to get specified ARM")
	}

	arm := ARM{}
	json.Unmarshal(armAsBytes, &arm)

	arm.Laboratory = append(arm.Laboratory, lab)

	armAsBytes, _ = json.Marshal(arm)
	APIstub.PutState(args[0], armAsBytes)

	return shim.Success(nil)
}

// ./executeTransaction.sh '{"Args":["createMarketingAuthorization", "OWNER1", "BAYER", "IBUPROFENO", "01/07/2018"]}' labcc
func (s *SmartContract) createMarketingAuthorization(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 4 {
		return shim.Error("Expecting 4 {OWNER, LAB, MEDICINE, DATE}")
	}

	/*chainCodeToCall := "arm"
	channelID := "mychannel"
	f := "addMarketingAuthorization"*/

	var permission = MarketingAuthorization{
		LaboratoryName: args[1],
		Medicine:       args[2],
		CreatedDate:    args[3],
		AuthDate:       "",
		Price:          "",
	}

	armAsBytes, err := APIstub.GetState(args[0])
	if err != nil {
		return shim.Error("Failed to get specified ARM")
	}
	arm := ARM{}
	json.Unmarshal(armAsBytes, &arm)

	arm.MarketingAuthorization = append(arm.MarketingAuthorization, permission)

	armAsBytes, _ = json.Marshal(arm)
	APIstub.PutState(args[0], armAsBytes)

	return shim.Success(nil)

	/*invokeArgs := toChaincodeArgs(f, args[0], args[1], args[2], args[3])
	response := APIstub.InvokeChaincode(chainCodeToCall, invokeArgs, channelID)
	if response.Status != shim.OK {
		errStr := fmt.Sprintf("Failed to invoke armcc. Got error: %s", string(response.Payload))
		fmt.Printf(errStr)
		return shim.Error(errStr)
	}

	fmt.Printf("Invoke armcc successful. Got response %s", string(response.Payload))

	return shim.Success(response.Payload)*/
}

/*func (s *SmartContract) addMarketingAuthorization(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	if len(args) != 4 {
		return shim.Error("Incorrect number of arguments. Expecting 4")
	}

	var permission = MarketingAuthorization{
		LaboratoryName: args[1],
		Medicine:       args[2],
		CreatedDate:    args[3],
		AuthDate:       "",
		Price:          "",
	}

	armAsBytes, err := APIstub.GetState(args[0])
	if err != nil {
		return shim.Error("Failed to get specified ARM")
	}

	arm := ARM{}
	json.Unmarshal(armAsBytes, &arm)

	arm.MarketingAuthorization = append(arm.MarketingAuthorization, permission)

	armAsBytes, _ = json.Marshal(arm)
	APIstub.PutState(args[0], armAsBytes)

	return shim.Success(nil)
}*/

// ./executeQuey.sh '{"Args":["queryByMarketingAuthorization", "OWNER1"]}' armcc
func (s *SmartContract) queryByMarketingAuthorization(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	if len(args[0]) == 0 {
		return shim.Error("Empty key. Expecting an ARM")
	}

	armAsBytes, _ := APIstub.GetState(args[0])

	if len(armAsBytes) == 0 {
		return shim.Error("Invalid key. Expecting an ARM")
	}

	return shim.Success(armAsBytes)
}

/*
func (s *SmartContract) createLaboratory(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	var lab = Laboratory{
		LaboratoryName: args[1],
	}

	assetAsBytes, _ := json.Marshal(lab)
	APIstub.PutState(args[0], assetAsBytes)

	return shim.Success(nil)
}
*/

func (s *SmartContract) queryLabsJSON(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	if len(args[0]) == 0 {
		return shim.Error("Empty key. Expecting an ARM")
	}

	armAsBytes, _ := APIstub.GetState(args[0])
	if len(armAsBytes) == 0 {
		return shim.Error("Invalid key. Expecting a LAB")
	}

	armStruct := ARM{}
	json.Unmarshal(armAsBytes, &armStruct)

	var buffer bytes.Buffer
	buffer.WriteString("[")

	first := true
	for _, lab := range armStruct.Laboratory {
		if first == false {
			buffer.WriteString(",")
		}
		buffer.WriteString("{")
		buffer.WriteString("\"LaboratoryName\":")
		buffer.WriteString("\"")
		buffer.WriteString(lab.LaboratoryName)
		buffer.WriteString("\"")
		buffer.WriteString("}")
	}

	buffer.WriteString("]")

	return shim.Success(buffer.Bytes())
}

// The main function is only relevant in unit test mode. Only included here for completeness.
func main() {
	// Create a new Smart Contract
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}
