package dk.sdu.mmmi.mdsd.interpreter

import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.Addition
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.Division
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.Literal
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.Multiplication
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.Subtraction
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.VariableDeclaration
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.VariableReference
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.EvaluateExpression

class MathAssignmentLanguageInterpreter {
	
	/**
	 * Start of recursive multi-dispatch methods for interpreting an expression
	 */
	def dispatch int compute(EvaluateExpression element) {
		element.expression.compute
	}
	
	def dispatch int compute(Addition expression) {
		expression.left.compute + expression.right.compute
	}
	
	def dispatch int compute(Subtraction expression) {
		expression.left.compute - expression.right.compute
	}
	
	def dispatch int compute(Multiplication expression) {
		expression.left.compute * expression.right.compute
	}
	
	def dispatch int compute(Division expression) {
		expression.left.compute / expression.right.compute
	}
	
	def dispatch int compute(VariableDeclaration declaration) {
		declaration.in.compute // result of a variable declaration expression should be the result of the 'in' expression
	}
	
	def dispatch int compute(VariableReference reference) {
		reference.variable.assignment.compute // result of a variable reference should be the variable's assignment
	}
	
	def dispatch compute(Literal expression) {
		expression.value
	}
	
}