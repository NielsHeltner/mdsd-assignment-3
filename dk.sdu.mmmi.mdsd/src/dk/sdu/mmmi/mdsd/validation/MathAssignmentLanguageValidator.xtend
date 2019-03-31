/*
 * generated by Xtext 2.16.0
 */
package dk.sdu.mmmi.mdsd.validation

import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.ExternalReference
import org.eclipse.xtext.validation.Check
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.MathAssignmentLanguagePackage

/**
 * This class contains custom validation rules. 
 *
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class MathAssignmentLanguageValidator extends AbstractMathAssignmentLanguageValidator {
	
	protected static val ISSUE_CODE_PREFIX = 'dk.sdu.mmmi.mdsd.math_assignment_language.'
	
	public static val INVALID_AMOUNT_ARGS = ISSUE_CODE_PREFIX + 'InvalidAmountArgs'
	
	@Check
	def checkExternalReferenceCorrectAmountArgs(ExternalReference ref) {
		val dec = ref.external
		val expected = dec.parameters.size
		val actual = ref.arguments.size
		if (actual != expected) {
			error('Invalid number of arguments. Expected ' + expected + ' but received ' + actual, 
					MathAssignmentLanguagePackage.Literals.EXTERNAL_REFERENCE__EXTERNAL, 
					INVALID_AMOUNT_ARGS)
		}
	}
	
}
