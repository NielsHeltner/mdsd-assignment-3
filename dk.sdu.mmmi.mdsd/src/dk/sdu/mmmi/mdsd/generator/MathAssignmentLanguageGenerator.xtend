/*
 * generated by Xtext 2.12.0
 */
package dk.sdu.mmmi.mdsd.generator

import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.Addition
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.Division
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.EvaluateExpression
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.ExternalDeclaration
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.ExternalReference
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.Literal
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.Multiplication
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.Parameter
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.Root
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.Subtraction
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.VariableDeclaration
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.VariableReference
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext

import static extension org.eclipse.xtext.EcoreUtil2.getAllContentsOfType
import static extension org.eclipse.xtext.EcoreUtil2.getContainerOfType
import static extension org.eclipse.xtext.EcoreUtil2.getAllContainers
import java.util.ArrayList

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class MathAssignmentLanguageGenerator extends AbstractGenerator {
	
	public static val GEN_FILE_EXT = ".java"
	
	public static val GEN_DIR = "math/"
	public static val GEN_FILE_NAME = "MathComputation"
	
	var Root root
	
	/**
	 * Represents the uppermost node of all variable declarations.
	 * This node's children are each roots, which each represent the variable declarations in an EvaluateExpression
	 */
	//var Node<VariableDeclaration> variableTree

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		root = resource.allContents.filter(Root).head
		
		val dir = GEN_DIR
		val pkg = dir.replaceAll("/", ".").substring(0, dir.length - 1) // convert path to package by converting all '/' to '.', and remove trailing '.'
		val fileName = GEN_FILE_NAME

		//variableTree = new Node
		//resource.allContents.filter(EvaluateExpression).forEach[collectVariableDeclarations]
		
		fsa.generateFile(dir + fileName + GEN_FILE_EXT, root.generateClass(pkg, fileName))
	}
	
	/**
	 * Initializes the collection of variable declarations in an EvaluateExpression.
	 */
	/*def collectVariableDeclarations(EvaluateExpression expression) {
		val root = new Node<VariableDeclaration>(variableTree)
		collectVariableDeclaration(expression, root)
		variableTree.getChildren.add(root)
	}*/
	
	/**
	 * Recursively goes through all variable declarations in the children of the input object, 
	 * and collect them according to their nested and parallel structure using a depth-first search.
	 * The while loop iterates through all variable declarations that are parallel, and for each one
	 * collect it, and then recursively its children.
	 *
	 * What is meant by parallel and nested is that e.g. in the expression:
	 * 		let x = 1 in let y = 2
	 * The two variable declarations are not parallel / not at the same layer of nesting, as one
	 * is nested in the other. While in the expression:
	 * 		let x = 1 + let y = 2
	 * They are not nested, but instead parallel.
	 */
	/*def private void collectVariableDeclaration(EObject input, Node<VariableDeclaration> node) {
	    val children = input.eAllContents
	    while(children.hasNext) {
			var candidate = children.next
			if (candidate instanceof VariableDeclaration) {
				children.prune // removes all elements nested in the last result of ::next (but keeps those parallel)
				val addedNode = node.add(candidate)
				collectVariableDeclaration(candidate, addedNode)
			}
		}
	}*/
    
    def indexOf(EObject input, VariableDeclaration target) {
    	val children = input.eAllContents
		var outerIndex = 0
    	while (children.hasNext) {
    		val candidate = children.next
    		if (candidate === target) {
    			return outerIndex
    		}
    		if (candidate instanceof VariableDeclaration || candidate instanceof EvaluateExpression) {
    			children.prune // removes all elements nested in the last result of ::next (but keeps those parallel)
    			val innerIndex = candidate.indexOf(target)
    			if (innerIndex !== null) {
    				return outerIndex -> innerIndex
    			}
    			outerIndex++
    		}
		}
    }
    
    def getDirectVariableDeclarations(EObject input) {
    	val children = input.eAllContents
    	val results = new ArrayList()
    	while (children.hasNext) {
    		val candidate = children.next
    		if (candidate instanceof VariableDeclaration) {
    			children.prune // removes all elements nested in the last result of ::next (but keeps those parallel)
    			results.add(candidate)
    		}
    	}
    	return results
    }
    
    def getParent(VariableDeclaration input) {
    	input.allContainers.filter(VariableDeclaration).head
    }
    
	def generateClass(Root root, String pkg, String name)'''
		�generateHeader�
		package �pkg�;
		
		public class �name� {
		
			public static interface Externals {
				
				�FOR external : root.elements.filter(ExternalDeclaration)�
					�external.generateMethod�;
					
				�ENDFOR�
			}
			
			private Externals externals;
			
			public �name�(Externals _externals) {
				externals = _externals;
			}
			
			public void compute() {
				�FOR evaluate : root.elements.filter(EvaluateExpression)�
					�evaluate.generateComputation�
				�ENDFOR�
			}
			
			�root.generateNestedInnerClass�
		}
	'''
	
	/**
	 * Iterates through a Node's children and generates nested inner classes for them.
	 */
	def generateNestedInnerClass(EObject parent)'''
		�FOR declaration: parent.directVariableDeclarations�
			�declaration.generateInnerClass�
			
		�ENDFOR�
	'''
	
	/**
	 * Recursively generates inner classes for 'let in's.
	 */
	def CharSequence generateInnerClass(VariableDeclaration declaration)'''
			class �declaration.generateInnerClassName� {
				
				private final int �declaration.name� = �declaration.generateAssignment�;
				
				public int compute() {
					return �declaration.in.generate�;
				}
				
				�declaration.generateNestedInnerClass�
			}
		'''
	
	/**
	 * Ensures that the generated code for an expression of the type:
	 * 		let x = 5 in let x = x
	 * can be resolved properly, by telling Java it should look in the outer class for the last 'x'.
	 */
	def generateAssignment(VariableDeclaration dec) { // TODO: refactor this method
		/*val expression = head.assignment
		val declarations = variableDeclarations.get(variableDeclarations.getIndex(head).key)
		expression.getAllContentsOfType(VariableReference).filter[variable.name == head.name].forEach[
			val ref = it
			val target = declarations.takeWhile[it !== head].findLast[name == ref.variable.name]
			variable.name = '''�target.generateInnerClassName�.this.�variable.name�'''
		]*/
		//expression.generate
		
		
		//val expression = dec.assignment
		//bug: hvis expression i sig selv er en VariableReference s� kommer den ikke med i forEach
		dec.assignment.getAllContentsOfType(VariableReference).filter[variable.name == dec.name].forEach[
			var candidate = dec
			var VariableDeclaration target
			while (target === null) {
				println('looking at ' + candidate)
				if (candidate != dec && candidate.name == variable.name) {
					target = candidate
					variable.name = '''�target.generateInnerClassName�.this.�variable.name�'''
				}
				candidate = candidate.parent
			}
		]
		dec.assignment.generate
	}
	
	def generateInnerClassName(VariableDeclaration declaration) {
		val name = root.indexOf(declaration).toString.replace("->", "_")
		'''Let�name�'''
	}
	
	def generateMethod(ExternalDeclaration dec)
		'''public int �dec.generateMethodSignature�'''
	
	def generateMethodSignature(ExternalDeclaration dec)
		'''�dec.name��dec.parameters.generateParameters�'''
	
	def generateParameters(Parameter... params)
		'''(�FOR param : params SEPARATOR ', '��param.type� �param.name��ENDFOR�)'''
	
	def generateComputation(EvaluateExpression evaluate)
		'''System.out.println(�evaluate.generate�);'''
	
	def generateHeader()'''
		/**
		 * Generated by MathAssignmentLanguage
		 */
 	'''
	
	/**
	 * Start of recursive multi-dispatch methods for displaying an arithmetic expression's complete syntax tree
	 */
	def dispatch CharSequence generate(EvaluateExpression element)
		'''"�element.label� " + �element.expression.generate�'''
	
	def dispatch CharSequence generate(Addition expression)
		'''(�expression.left.generate� + �expression.right.generate�)'''
	
	def dispatch CharSequence generate(Subtraction expression)
		'''(�expression.left.generate� - �expression.right.generate�)'''
	
	def dispatch CharSequence generate(Multiplication expression)
		'''(�expression.left.generate� * �expression.right.generate�)'''
	
	def dispatch CharSequence generate(Division expression)
		'''(�expression.left.generate� / �expression.right.generate�)'''
	
	def dispatch CharSequence generate(VariableDeclaration declaration)
		'''new �declaration.generateInnerClassName�().compute()'''
	
	def dispatch CharSequence generate(VariableReference reference)
		'''�reference.variable.name�'''
	
	def dispatch CharSequence generate(ExternalReference reference)
		'''externals.�reference.external.name�(�FOR argument : reference.arguments SEPARATOR ', '��argument.generate��ENDFOR�)'''
	
	def dispatch generate(Literal expression)
		'''�expression.value�'''
	
}