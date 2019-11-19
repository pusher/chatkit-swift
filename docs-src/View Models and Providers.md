# View Models and Providers

The state of the chats which your user is engaged in is exposed to you by the
SDK via View Models and Providers.

Both view models and providers expose a value or collection, which is updated
in real time in response to your actions and events received from other users.
Both also take delegate implementations from you so you can be notified when
these changes take place and update your application / UI appropriately.

While both expose the data to you, they operate at different levels of
abstraction, and are layered by the SDK:

```
+--------------------------------+
| UI (you provide)               |
+--------------------------------+
                ^
+--------------------------------+
| View Models                    |
+--------------------------------+
                ^
+--------------------------------+
| Providers                      |
+--------------------------------+
                ^
+--------------------------------+
| Network (internal to the SDK)  |
+--------------------------------+
```

## Providers

Providers expose chat data in a representation close to the Chatkit domain
model.

Each provider exposes a collection of Chatkit entities, and invokes delegate
methods which describe events in the Chatkit system.

For example, the `TypingUsersProvider`

- exposes the collection of `User`s who are typing in a given `Room`,
  - exposes the collection as a `Set`, because there is no natural ordering
    for those users,
- has delegate methods which are invoked when a user starts typing and when a
  user stops typing.

## View Models

View models map the Chatkit entities exposed by a provider to something which
should match more closely to the on screen representation of that data.

Each view model exposes a value or collection of values which map to the
contents of a UI component.

For example, the `TypingUsersViewModel`

- exposes a `String?` describing which users are typing in a given `Room`,
  - each user is represented by the `name` field from the `User` object,
    - if the `name` field is blank, the value `Anonymous user` is used in
      place,
  - the list of users is sorted by their name, and the list is truncated at a
    certain number of users to say `... and other users`,
  - the string ends with `is typing` or `are typing` as appropriate,
  - evalulates to `nil` if no users are typing,
- has a single delegate method which is invoked when the exposed value
  changes.

# Which to use

This will depend on the specifics of your use case, but in general we
recommend using the provided view models when possible. They encapsulate a lot
of logic which will likely be common to many use cases. The typing users
example above is a very simple case of a view model.

However, because view models must encapsulate a lot of decisions about how
data should be presented, they are provided as conveniences and their use is
entirely optional.

For example, a shortcoming of the `TypingUsersViewModel` presented above is
that it exposes an english description of the typing users. Another example is
that it uses the full `name` field of the user in the description, but you may
want to split this field to extract only the first name, for example, or use a
nickname field which you maintain in the custom metadata on the `User`.

The view models are intended to serve common use cases, and then serve as
examples for guidance when the details of your system no longer match what
they provide and you wish to implement your own transformations on top of the
entities exposed by the providers.
