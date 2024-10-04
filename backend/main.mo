import Array "mo:base/Array";
import Bool "mo:base/Bool";
import Hash "mo:base/Hash";

import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Text "mo:base/Text";

actor {
  type ShoppingItem = {
    id: Nat;
    text: Text;
    completed: Bool;
  };

  stable var nextId: Nat = 0;
  stable var itemEntries: [(Nat, ShoppingItem)] = [];

  var items = HashMap.fromIter<Nat, ShoppingItem>(itemEntries.vals(), 10, Nat.equal, Nat.hash);

  public func addItem(text: Text) : async Nat {
    let id = nextId;
    let item: ShoppingItem = {
      id;
      text;
      completed = false;
    };
    items.put(id, item);
    nextId += 1;
    id
  };

  public query func getItems() : async [ShoppingItem] {
    Iter.toArray(items.vals())
  };

  public func toggleItem(id: Nat) : async Bool {
    switch (items.get(id)) {
      case (null) { false };
      case (?item) {
        let updatedItem: ShoppingItem = {
          id = item.id;
          text = item.text;
          completed = not item.completed;
        };
        items.put(id, updatedItem);
        true
      };
    }
  };

  public func deleteItem(id: Nat) : async Bool {
    switch (items.remove(id)) {
      case (null) { false };
      case (?_) { true };
    }
  };

  system func preupgrade() {
    itemEntries := Iter.toArray(items.entries());
  };

  system func postupgrade() {
    itemEntries := [];
  };
}
