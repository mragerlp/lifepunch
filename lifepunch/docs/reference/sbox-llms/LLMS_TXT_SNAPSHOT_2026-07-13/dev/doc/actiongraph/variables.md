# Variables

Variables are useful for making your graph easier to understand, cleaning up link spaghetti, and when performing calculations in loops.


![A simple example setting and getting an example variable](https://cdn.sbox.game/doc/actiongraph/images/a-simple-example-setting-and-getting-an-example-variable.png)

You can create a new variable by dragging a link from an output with the value type you want the variable to hold, selecting "Add Variable", then giving it a name.


![Creating a new Vector3 variable named "Example".](https://cdn.sbox.game/doc/actiongraph/images/creating-a-new-vector3-variable-named-example.png)

This will create an action node that sets the new variable upon receiving an input signal. You can then create more nodes to get or set the value of the variable by right-clicking, then looking under *Variables*.


![Creating a node to get or set the "Example" variable.](https://cdn.sbox.game/doc/actiongraph/images/creating-a-node-to-get-or-set-the-example-variable.png)

You can also directly use a variable in an input socket by right-clicking on it, then selecting the variable from the context menu.


![Directly using a variable in an input socket.](https://cdn.sbox.game/doc/actiongraph/images/directly-using-a-variable-in-an-input-socket.png)
