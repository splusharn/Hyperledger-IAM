/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

'use strict';
/**
 * Write your transction processor functions here
 */

/**
 * Sample transaction
 * @param {org.acme.mynetwork.AddGroupMembership} AddGroupMembership
 * @transaction
 */
async function AddGroupMembership(transaction) {
    // Update the asset with the new value.
  	if(!transaction.groupId.members) {
        transaction.groupId.members = [];
    }
  	if(!transaction.accountId.memberOf) {
        transaction.accountId.memberOf = [];
    }
    transaction.accountId.memberOf.push(transaction.groupId);
    transaction.groupId.members.push(transaction.accountId);

    // Get the asset registry for the asset.
    const accountRegistry = await getAssetRegistry('org.acme.mynetwork.Account');
    const groupRegistry = await getAssetRegistry('org.acme.mynetwork.Group');
    
    // Update the asset in the asset registry.
    await accountRegistry.update(transaction.accountId);
    await groupRegistry.update(transaction.groupId);

    // Emit an event for the modified asset.
    let event = getFactory().newEvent('org.acme.mynetwork', 'Request');
    event.personId = transaction.accountId.owner.uid;
    event.accountId = transaction.accountId.eruid;
    event.description = "A group membership was added to the account";
    event.requestId = "1";
    emit(event);
}

/**
 * Sample transaction
 * @param {org.acme.mynetwork.AddRoleMembership} AddRoleMembership
 * @transaction
 */
async function AddRoleMembership(transaction) {
  // Update the asset with the new value.
  if(!transaction.roleId.members) {
      transaction.roleId.members = [];
  }
  if(!transaction.personId.memberOf) {
      transaction.personId.memberOf = [];
  }
  transaction.personId.memberOf.push(transaction.roleId);
  transaction.roleId.members.push(transaction.personId);

  // Get the asset registry for the asset.
  const participantRegistry = await getParticipantRegistry('org.acme.mynetwork.Person');
  const roleRegistry = await getAssetRegistry('org.acme.mynetwork.Role');
  
  // Update the asset in the asset registry.
  await participantRegistry.update(transaction.personId);
  await roleRegistry.update(transaction.roleId);

  // Emit an event for the modified asset.
  let event = getFactory().newEvent('org.acme.mynetwork', 'Request');
  event.personId = transaction.personId.uid;
  event.description = "A role membership was added to the person";
  event.requestId = "1";
  emit(event);
}

/**
 * Create an account
 * @param {org.acme.mynetwork.CreateAccount} CreateAccount
 * @transaction
 */
async function CreateAccount(transaction) {
  	// Get the asset registry for the asset.
    const accountRegistry = await getAssetRegistry('org.acme.mynetwork.Account');
    var account = getFactory().newResource('org.acme.mynetwork', 'Account', transaction.personId.uid);
    account.owner = transaction.personId;
  
  	if(!account.owner.accounts) {
        account.owner.accounts = [];
    }
    account.owner.accounts.push(account);
  
  	return getAssetRegistry('org.acme.mynetwork.Account').then(function (assetRegistry) {
        return assetRegistry.add(account);
    }).then(function() {	
  		return getParticipantRegistry('org.acme.mynetwork.Person').then(function (participantRegistry) {
      		return participantRegistry.update(account.owner);
    	});
    }).then(function() {
      // Emit an event for the modified asset.
      var event = getFactory().newEvent('org.acme.mynetwork', 'Request');
      event.personId = transaction.personId.uid;
      event.accountId = transaction.personId.eruid;
      event.description = "An account was added to the person";
      event.requestId = "1";
      emit(event);
    });
}

/**
 * Create a group
 * @param {org.acme.mynetwork.CreateGroup} CreateGroup
 * @transaction
 */
async function CreateGroup(transaction) {
  // Get the asset registry for the asset.
  const groupRegistry = await getAssetRegistry('org.acme.mynetwork.Group');
  var group = getFactory().newResource('org.acme.mynetwork', 'Group', transaction.groupName);

  return getAssetRegistry('org.acme.mynetwork.Group').then(function (assetRegistry) {
      return assetRegistry.add(group);	
  }).then(function() {
    // Emit an event for the modified asset.
    var event = getFactory().newEvent('org.acme.mynetwork', 'Request');
    event.groupId = transaction.groupName;
    event.description = "A Group asset was added";
    event.requestId = "1";
    emit(event);
  });
}

/**
 * Create a role
 * @param {org.acme.mynetwork.CreateRole} CreateRole
 * @transaction
 */
async function CreateRole(transaction) {
  // Get the asset registry for the asset.
  const roleRegistry = await getAssetRegistry('org.acme.mynetwork.Role');
  var role = getFactory().newResource('org.acme.mynetwork', 'Role', transaction.roleName);

  return getAssetRegistry('org.acme.mynetwork.Role').then(function (assetRegistry) {
      return assetRegistry.add(role);	
  }).then(function() {
    // Emit an event for the modified asset.
    var event = getFactory().newEvent('org.acme.mynetwork', 'Request');
    event.roleId = transaction.roleName;
    event.description = "A Role asset was added";
    event.requestId = "1";
    emit(event);
  });    
}