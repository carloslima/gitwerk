import DS from 'ember-data';
import attr from 'ember-data/attr';
import { computed } from '@ember/object';

const Repository = DS.Model.extend({
  slug: attr(),
  name: attr(),
  namespace: attr(),
  privacy: attr(),
  permissions: attr(),
  trees: DS.hasMany('tree', {async: true}),

  defaultTree: computed(function () {
    let defaultTree = this.get('trees').filter(tree => tree.id == 'master');
    return defaultTree[0];
  }),
});

Repository.reopenClass({
  fetchBySlug(store, slug) {
    let adapter, modelClass, promise;
    promise = null;
    adapter = store.adapterFor('repository');
    modelClass = store.modelFor('repository');
    promise = adapter.findRecord(store, modelClass, slug).then((payload) => {
      let i, len, record, ref, repo, result, serializer;
      serializer = store.serializerFor('repository');
      modelClass = store.modelFor('repository');
      result = serializer.normalizeResponse(store, modelClass, payload, null, 'findRecord');
      repo = store.push({
        data: result.data
      });
      return repo;
    });
    return promise['catch'](() => {
      let error;
      error = new Error('repository not found');
      error.slug = slug;
      throw error;
    });
  }
});

export default Repository;
