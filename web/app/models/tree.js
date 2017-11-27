import DS from 'ember-data';

export default DS.Model.extend({
  treeType: DS.attr(),
  treeEntries: DS.hasMany('treeEntry'),
  repository: DS.belongsTo('repository'),
});
