/*
 * generated by Xtext 2.12.0
 */
package dk.sdu.mmmi.mdsd.generator

import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.Addition
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.Division
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.EvaluateExpression
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.Expression
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.ExternalDeclaration
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.ExternalReference
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.Literal
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.Multiplication
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.Parameter
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.Root
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.Subtraction
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.VariableDeclaration
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.VariableReference
import java.util.HashSet
import java.util.List
import java.util.Set
import java.util.concurrent.CopyOnWriteArrayList
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext

import static extension org.eclipse.xtext.EcoreUtil2.getAllContainers
import static extension org.eclipse.xtext.EcoreUtil2.getAllContentsOfType

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class MathAssignmentLanguageGenerator extends AbstractGenerator {
	
	public static val GEN_FILE_EXT = ".java"
	
	public static val GEN_DIR = "math/"
	public static val GEN_FILE_NAME = "MathComputation"
	
	/**
	 * Data structure the represents the nested structure and scope of 'let in's.
	 * The outer list mimics the scope of each 'let in' that is not declared inside another,
	 * and the inner list mimics the nested structure of the outer 'let in'.
	 */
	val List<List<VariableDeclaration>> variableDeclarations = new CopyOnWriteArrayList()

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		val root = resource.allContents.filter(Root).head
		
		val dir = GEN_DIR
		val pkg = dir.replaceAll("/", ".").substring(0, dir.length - 1) // convert path to package by converting all '/' to '.', and remove trailing '.'
		val fileName = GEN_FILE_NAME
		
		variableDeclarations.clear
		variableDeclarations.add(new CopyOnWriteArrayList())
		resource.allContents.filter(EvaluateExpression).forEach[collectVariableDeclarations]
		
		fsa.generateFile(dir + fileName + GEN_FILE_EXT, root.generateClass(pkg, fileName))
	}
	
	/**
	 * This method acts as a local state for the tail recursive method "collectVariableDeclaration", 
	 * as it contains the accumulated seenContainerSizes.
	 */
	def collectVariableDeclarations(EvaluateExpression expression) {
		val seenContainerSizes = new HashSet()
		expression.getAllContentsOfType(VariableDeclaration).collectVariableDeclaration(seenContainerSizes)
	}
	
	/**
	 * Tail recursive method that goes through all VariableDeclarations. If a VariableDeclaration is met 
	 * with the same layer/depth of nesting as a previous one, a new collection is created (as these should 
	 * not share scope), and all future VariableDeclarations are added to that list, until another VariableDeclaration 
	 * is met with the same depth of nesting.
	 */
	def private void collectVariableDeclaration(Iterable<VariableDeclaration> declarations, Set<Integer> seenContainerSizes) {
		val head = declarations.head
		val tail = declarations.tail
		
		if (!seenContainerSizes.add(head.allContainers.size)) {
			val List<VariableDeclaration> inner = new CopyOnWriteArrayList()
			inner.add(head)
			variableDeclarations.add(inner)
		}
		else {
			variableDeclarations.last.add(head)
		}
		tail.collectVariableDeclaration(seenContainerSizes)
	}
	
	/**
	 * Helper method that allows searching for elements that are nested one layer.
	 * Returns the index of both the outer and inner collections.
	 */
	def getIndex(List<List<VariableDeclaration>> container, VariableDeclaration target) {
		for (i : 0 ..< container.size) {
			val list = container.get(i)
			val index = list.indexOf(target)
			if (index != -1) {
				return i -> index
			}
		}
		return -1 -> -1
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
			
			�FOR declarations : variableDeclarations�
				�declarations.generateInnerClass�
			�ENDFOR�
			
		}
	'''
	
	/**
	 * Recursively generates nested inner classes for 'let in's.
	 */
	def CharSequence generateInnerClass(Iterable<VariableDeclaration> declarations) {
		val head = declarations.head
		val tail = declarations.tail
		'''
			class �head.generateInnerClassName� {
				
				private final int �head.name� = �head.assignment.generateAssignment(declarations)�;
				
				public int compute() {
					return �head.in.generate�;
				}
				
				�IF !tail.isEmpty�
					�tail.generateInnerClass�
				�ENDIF�
				
			}
		'''
	}
	
	/**
	 * Makes sure that the generated code for an expression of the type:
	 * 		let x = 5 in let x = x end end
	 * can be resolved properly, by telling Java it should look in the outer class for the last 'x'.
	 */
	def generateAssignment(Expression expression, Iterable<VariableDeclaration> declarations) {
		val head = declarations.head
		expression.getAllContentsOfType(VariableReference).filter[variable.name == head.name].forEach[
			val ref = it
			val target = declarations.findLast[name == ref.variable.name]
			variable.name = '''�target.generateInnerClassName�.this.�variable.name�'''
		]
		expression.generate
	}
	
	def generateInnerClassName(VariableDeclaration declaration) {
		val indices = variableDeclarations.getIndex(declaration)
		'''Let�indices.key�_�indices.value�'''
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
	
	def dispatch CharSequence generate(VariableDeclaration declaration) {
		//'''�declaration.in.generate�'''
		//variableDeclarations.add(declaration)
		'''new �declaration.generateInnerClassName�().compute()'''
	}
	
	def dispatch CharSequence generate(VariableReference reference)
		//'''�reference.variable.assignment.generate�'''
		//'''new Let�map.indexOf(reference.variable)�().compute()'''
		'''�reference.variable.name�'''
	
	def dispatch CharSequence generate(ExternalReference reference)
		'''externals.�reference.external.name�(�FOR argument : reference.arguments SEPARATOR ', '��argument.generate��ENDFOR�)'''
	
	def dispatch generate(Literal expression)
		'''�expression.value�'''
	
}