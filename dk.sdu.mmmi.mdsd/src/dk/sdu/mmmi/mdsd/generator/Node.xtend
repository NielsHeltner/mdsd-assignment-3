package dk.sdu.mmmi.mdsd.generator

import java.util.List
import java.util.ArrayList
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class Node<T> {
	
	var Node<T> parent
    var T data
    val List<Node<T>> childs = new ArrayList()

	new() {}
	
	new(Node<T> parent) {
		this.parent = parent
	}

	new(T data, Node<T> parent) {
		this.data = data
		this.parent = parent
	}
	
	def isTree() {
		return parent === null
	}
	
	def isRoot() {
		return data === null
	}
	
	def isLeaf() {
		return childs.empty
	}

    def add(T data) {
        val addedNode = new Node(data, this)
        childs.add(addedNode)
        return addedNode
    }
    
    /**
	 * Helper method that allows searching for elements that are nested one layer.
	 * Returns the index of both the outer and inner collections.
	 */
    def indexOf(T target) {
    	for (outerIndex : 0 ..< childs.size) {
    		if (childs.get(outerIndex).data == target) {
    			return outerIndex
    		}
			val innerIndex = childs.get(outerIndex).indexOf(target)
			if (innerIndex != -1) {
				return outerIndex -> innerIndex
			}
    	}
    	return -1
    }
    
    def Node<T> nodeOf(T target) {
    	for (child : childs) {
    		if (child.data == target) {
    			return child
    		}
			val candidate = child.nodeOf(target)
			if (candidate !== null) {
				return candidate
			}
    	}
    }

}