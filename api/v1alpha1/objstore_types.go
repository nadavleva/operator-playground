/*
Copyright 2025.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package v1alpha1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// EDIT THIS FILE!  THIS IS SCAFFOLDING FOR YOU TO OWN!
// NOTE: json tags are required.  Any new fields you add must have json tags for the fields to be serialized.
const (
	PENDING_STATE  = "PENDING"
	CREATED_STATE  = "CREATED"
	CREATING_STATE = "CREATING"
	ERROR_STATE    = "ERROR"
)

// ObjStoreSpec defines the desired state of ObjStore
type ObjStoreSpec struct {
	// INSERT ADDITIONAL SPEC FIELDS - desired state of cluster
	// Important: Run "make" to regenerate code after modifying this file
	// The following markers will use OpenAPI v3 schema to validate the value
	// More info: https://book.kubebuilder.io/reference/markers/crd-validation.html

	// Name is the name of the ObjStore we want to create and must be at least 4 characters long
	// +kubebuilder:validation:MinLength=4
	// +optional
	Name *string `json:"name,omitempty"`

	// Locked prevents deletion of binary objects from the ObjStore
	Locked *bool `json:"locked,omitempty"`
}

// ObjStoreStatus defines the observed state of ObjStore.
type ObjStoreStatus struct {
	State string `json:"state"`
}

// +kubebuilder:object:root=true
// +kubebuilder:subresource:status
// +kubebuilder:printcolumn:name="State",type=string,JSONPath=`.status.state`

// ObjStore is the Schema for the objstores API
type ObjStore struct {
	metav1.TypeMeta `json:",inline"`

	// metadata is a standard object metadata
	// +optional
	metav1.ObjectMeta `json:"metadata,omitempty,omitzero"`

	// spec defines the desired state of ObjStore
	// +required
	Spec ObjStoreSpec `json:"spec"`

	// status defines the observed state of ObjStore
	// +optional
	Status ObjStoreStatus `json:"status,omitempty,omitzero"`
}

// +kubebuilder:object:root=true

// ObjStoreList contains a list of ObjStore
type ObjStoreList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty"`
	Items           []ObjStore `json:"items"`
}

func init() {
	SchemeBuilder.Register(&ObjStore{}, &ObjStoreList{})
}
