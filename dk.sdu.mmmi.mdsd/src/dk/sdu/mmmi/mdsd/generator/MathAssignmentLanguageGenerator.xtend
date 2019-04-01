/*
 * generated by Xtext 2.12.0
 */
package dk.sdu.mmmi.mdsd.generator

import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.Addition
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.Division
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.EvaluateExpression
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.ExternalDeclaration
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.In
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.Literal
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.Multiplication
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.Parameter
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.Root
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.Subtraction
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.VariableDeclaration
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.VariableReference
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.ExternalReference

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class MathAssignmentLanguageGenerator extends AbstractGenerator {
	
	public static val GEN_FILE_EXT = ".java"
	
	public static val GEN_DIR = "math/"
	public static val GEN_FILE_NAME = "MathComputation"

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		val root = resource.allContents.filter(Root).head
		root.elements.forEach[
			println(display)
		]
		
		val dir = GEN_DIR
		val pkg = dir.replaceAll("/", ".").substring(0, dir.length - 1) // convert path to package by converting all '/' to '.', and remove trailing '.'
		val fileName = GEN_FILE_NAME
		
		fsa.generateFile(dir + fileName + GEN_FILE_EXT, root.generateClass(pkg, fileName))
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
		
		}
	'''
	
	def generateComputation(EvaluateExpression evaluate)
		'''System.out.println(�evaluate.display�);'''
	
	def generateMethod(ExternalDeclaration dec)
		'''public int �dec.generateMethodSignature�'''
	
	def generateMethodSignature(ExternalDeclaration dec)
		'''�dec.name��dec.parameters.generateParameters�'''
	
	def generateParameters(Parameter... params)
		'''(�FOR param : params SEPARATOR ', '��param.type� �param.name��ENDFOR�)'''
	
	def generateHeader()'''
		/**
		 * Generated by MathAssignmentLanguage
		 */
 	'''
	
	/**
	 * Start of recursive multi-dispatch methods for displaying an arithmetic expression's complete syntax tree
	 */
	def dispatch CharSequence display(EvaluateExpression element)
		'''"�element.label� " + �element.expression.display�'''
	
	def dispatch CharSequence display(Addition expression)
		'''(�expression.left.display� + �expression.right.display�)'''
	
	def dispatch CharSequence display(Subtraction expression)
		'''(�expression.left.display� - �expression.right.display�)'''
	
	def dispatch CharSequence display(Multiplication expression)
		'''(�expression.left.display� * �expression.right.display�)'''
	
	def dispatch CharSequence display(Division expression)
		'''(�expression.left.display� / �expression.right.display�)'''
	
	def dispatch CharSequence display(VariableDeclaration declaration)
		'''var �declaration.name� = �declaration.expression.display��IF declaration.in !== null��declaration.in.display��ENDIF�'''
	
	def dispatch CharSequence display(In in)
		''' in �in.expression.display�'''
	
	def dispatch CharSequence display(VariableReference reference)
		'''�reference.variable.expression.display�'''
	
	def dispatch CharSequence display(ExternalDeclaration declaration)
		'''external �declaration.name�(�FOR parameter : declaration.parameters SEPARATOR ', '��parameter.type� �parameter.name��ENDFOR�)'''
	
	def dispatch CharSequence display(ExternalReference reference)
		'''externals.�reference.external.name�(�FOR argument : reference.arguments SEPARATOR ', '��argument.display��ENDFOR�)'''
	
	def dispatch display(Literal expression)
		'''�expression.value�'''
	
}