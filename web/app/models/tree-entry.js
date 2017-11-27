import DS from 'ember-data';
import { computed } from '@ember/object';

const treeEntry = DS.Model.extend({
  name: DS.attr(),
  entryType: DS.attr(),

  isTree: computed(function () {
    return this.get('entryType') == "tree";
  })
});

treeEntry.reopenClass({
  fetchByRepoAndTree(repository, tree, path) {
    //build the path based on repo, tree_id, and path
  }
});

export default treeEntry;
