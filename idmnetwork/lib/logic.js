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
    //vent.accountT = transaction.accountId.type;
    event.description = "A membership was added to the account";
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
    //account.type = transaction.type;
    account.owner = transaction.personId;

    if(!account.owner.accounts) {
        account.owner.accounts = [];
    }
    account.owner.accounts.push(account);
  
    return getAssetRegistry('org.acme.mynetwork.Account').then(function (assetRegistry) {
        return assetRegistry.add(account);
    });

    // Emit an event for the modified asset.
    let event = getFactory().newEvent('org.acme.mynetwork', 'Request');
    event.personId = transaction.accountId.owner.uid;
    event.accountId = transaction.accountId.eruid;
    //event.accountT = transaction.accountId.type;
    event.description = "An account was added to the person";
    event.requestId = "1";
    emit(event);
}