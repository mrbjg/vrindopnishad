const { queryRef, executeQuery, validateArgsWithOptions, mutationRef, executeMutation, validateArgs } = require('firebase/data-connect');

const ContentStatus = {
  DRAFT: "DRAFT",
  PUBLISHED: "PUBLISHED",
  ARCHIVED: "ARCHIVED",
}
exports.ContentStatus = ContentStatus;

const connectorConfig = {
  connector: 'content',
  service: 'vrindavaani',
  location: 'us-east4'
};
exports.connectorConfig = connectorConfig;

const upsertContentRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'UpsertContent', inputVars);
}
upsertContentRef.operationName = 'UpsertContent';
exports.upsertContentRef = upsertContentRef;

exports.upsertContent = function upsertContent(dcOrVars, vars) {
  const { dc: dcInstance, vars: inputVars } = validateArgs(connectorConfig, dcOrVars, vars, true);
  return executeMutation(upsertContentRef(dcInstance, inputVars));
}
;

const deleteContentRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return mutationRef(dcInstance, 'DeleteContent', inputVars);
}
deleteContentRef.operationName = 'DeleteContent';
exports.deleteContentRef = deleteContentRef;

exports.deleteContent = function deleteContent(dcOrVars, vars) {
  const { dc: dcInstance, vars: inputVars } = validateArgs(connectorConfig, dcOrVars, vars, true);
  return executeMutation(deleteContentRef(dcInstance, inputVars));
}
;

const getContentByIdRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetContentById', inputVars);
}
getContentByIdRef.operationName = 'GetContentById';
exports.getContentByIdRef = getContentByIdRef;

exports.getContentById = function getContentById(dcOrVars, varsOrOptions, options) {
  
  const { dc: dcInstance, vars: inputVars, options: inputOpts } = validateArgsWithOptions(connectorConfig, dcOrVars, varsOrOptions, options, true, true);
  return executeQuery(getContentByIdRef(dcInstance, inputVars), inputOpts && inputOpts.fetchPolicy);
}
;

const getContentBySlugRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'GetContentBySlug', inputVars);
}
getContentBySlugRef.operationName = 'GetContentBySlug';
exports.getContentBySlugRef = getContentBySlugRef;

exports.getContentBySlug = function getContentBySlug(dcOrVars, varsOrOptions, options) {
  
  const { dc: dcInstance, vars: inputVars, options: inputOpts } = validateArgsWithOptions(connectorConfig, dcOrVars, varsOrOptions, options, true, true);
  return executeQuery(getContentBySlugRef(dcInstance, inputVars), inputOpts && inputOpts.fetchPolicy);
}
;

const listContentRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'ListContent', inputVars);
}
listContentRef.operationName = 'ListContent';
exports.listContentRef = listContentRef;

exports.listContent = function listContent(dcOrVars, varsOrOptions, options) {
  
  const { dc: dcInstance, vars: inputVars, options: inputOpts } = validateArgsWithOptions(connectorConfig, dcOrVars, varsOrOptions, options, true, true);
  return executeQuery(listContentRef(dcInstance, inputVars), inputOpts && inputOpts.fetchPolicy);
}
;

const listAllContentRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'ListAllContent', inputVars);
}
listAllContentRef.operationName = 'ListAllContent';
exports.listAllContentRef = listAllContentRef;

exports.listAllContent = function listAllContent(dcOrVars, varsOrOptions, options) {
  
  const { dc: dcInstance, vars: inputVars, options: inputOpts } = validateArgsWithOptions(connectorConfig, dcOrVars, varsOrOptions, options, true, false);
  return executeQuery(listAllContentRef(dcInstance, inputVars), inputOpts && inputOpts.fetchPolicy);
}
;

const syncContentUpdatesRef = (dcOrVars, vars) => {
  const { dc: dcInstance, vars: inputVars} = validateArgs(connectorConfig, dcOrVars, vars, true);
  dcInstance._useGeneratedSdk();
  return queryRef(dcInstance, 'SyncContentUpdates', inputVars);
}
syncContentUpdatesRef.operationName = 'SyncContentUpdates';
exports.syncContentUpdatesRef = syncContentUpdatesRef;

exports.syncContentUpdates = function syncContentUpdates(dcOrVars, varsOrOptions, options) {
  
  const { dc: dcInstance, vars: inputVars, options: inputOpts } = validateArgsWithOptions(connectorConfig, dcOrVars, varsOrOptions, options, true, true);
  return executeQuery(syncContentUpdatesRef(dcInstance, inputVars), inputOpts && inputOpts.fetchPolicy);
}
;
