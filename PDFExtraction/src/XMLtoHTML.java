import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;


public class XMLtoHTML {
	public String getHTML(byte[] tetml) throws FileNotFoundException, TransformerException {
		TransformerFactory tFactory = TransformerFactory.newInstance();
		ByteArrayOutputStream output = new ByteArrayOutputStream();
	    Transformer transformer =
	      tFactory.newTransformer
	         (new javax.xml.transform.stream.StreamSource
	            ("tetml2html.xsl"));
	    transformer.transform
	      (new javax.xml.transform.stream.StreamSource
	            (new ByteArrayInputStream(tetml)),
	       new javax.xml.transform.stream.StreamResult
	            (output));
	    return output.toString();
	}
}
