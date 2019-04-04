package dk.sdu.mmmi.mdsd.generator

import java.util.List
import java.util.ArrayList
import org.eclipse.xtend.lib.annotations.Accessors
	
/**
 * Composite tree data structure for representing the nested structure and scope of 'let in's.
 * The 'data' attribute refers to a variable declarations, and the 'children' attribute refers
 * to all variable declarations nested inside.
 */
@Accessors
class Node<T> {
	
	var Node<T> parent
    var T data
    val List<Node<T>> children = new ArrayList()

	new() {}
	
	new(Node<T> parent) {
		this.parent = parent
	}

	new(T data, Node<T> parent) {
		this.data = data
		this.parent = parent
	}

    def add(T data) {
        val addedNode = new Node(data, this)
        children.add(addedNode)
        return addedNode
    }
    
    /**
     * Returns nested pairs of integers representing the nested and parallel structure
     * of the target variable declaration's location.
	 */
    def indexOf(T target) {
    	for (outerIndex : 0 ..< children.size) {
    		if (children.get(outerIndex).data == target) {
    			return outerIndex
    		}
			val innerIndex = children.get(outerIndex).indexOf(target)
			if (innerIndex != -1) {
				return outerIndex -> innerIndex
			}
    	}
    	return -1
    }
    
    /**
     * Returns the node that represents the target variable declaration.
     */
    def Node<T> nodeOf(T target) {
    	for (child : children) {
    		if (child.data == target) {
    			return child
    		}
			val candidate = child.nodeOf(target)
			if (candidate !== null) {
				return candidate
			}
    	}
    }
    
	def isTree() {
		return parent === null
	}
	
	def isRoot() {
		return data === null
	}
	
	def isLeaf() {
		return children.empty
	}

}