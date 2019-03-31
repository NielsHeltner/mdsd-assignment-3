package dk.sdu.mmmi.mdsd.ui.hover

import com.google.inject.Inject
import dk.sdu.mmmi.mdsd.interpreter.MathAssignmentLanguageInterpreter
import dk.sdu.mmmi.mdsd.mathAssignmentLanguage.Element
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.Diagnostician
import org.eclipse.xtext.ui.editor.hover.html.DefaultEObjectHoverProvider

import static extension org.eclipse.emf.ecore.util.EcoreUtil.*

class MathAssignmentLanguageEObjectHoverProvider extends DefaultEObjectHoverProvider {

	@Inject
	extension MathAssignmentLanguageInterpreter

	override getHoverInfoAsHtml(EObject object) {
		if (object.programHasNoErrors && object instanceof Element) {
			return '''
				<p>
				result = <b>«object.compute»</b>
				</p>
			'''
		}
		else {
			return super.getHoverInfoAsHtml(object)
		}
	}

	/**
	 * Manually invoke the validator, since the interpreter expects a complete, 
	 * valid model.
	 */
	def private programHasNoErrors(EObject object) {
		Diagnostician.INSTANCE.validate(object.rootContainer).children.empty
	}

}
