import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;

import javax.xml.transform.TransformerException;

import com.pdflib.TETException;


public class PDFtoHTML {
	private PDFtoXML doc=null;
	private int cur_page = 0;

	public void openFile(String filename) throws TETException {
		doc = new PDFtoXML("Ex1.1-10.pdf");
		cur_page = 0;
	}
	public String getPageAt(int page_no) throws TETException, FileNotFoundException, TransformerException {
		doc.startXML();
		doc.getPageAt(page_no);
		doc.endXML();
		byte[] tetml = doc.getXML();
		XMLtoHTML translator = new XMLtoHTML();
		return translator.getHTML(tetml);
	}
	public String getNextPage() throws TETException, FileNotFoundException, TransformerException {
		return getPageAt(++cur_page);
	}
	
	public String getPreviousPage() throws TETException, FileNotFoundException, TransformerException {
		return getPageAt(--cur_page);
	}
	
	public String getDocument() throws TETException, FileNotFoundException, TransformerException {
		doc.startXML();
		doc.getAllPages();
		doc.endXML();
		byte[] tetml = doc.getXML();
		XMLtoHTML translator = new XMLtoHTML();
		return translator.getHTML(tetml);
	}
	
	public static void main(String[] args) throws TETException, FileNotFoundException, TransformerException, UnsupportedEncodingException {
		PDFtoHTML reader = new PDFtoHTML();
		reader.openFile("Ex1.1-10.pdf");
		PrintWriter writer = new PrintWriter("output.html", "UTF-8");
		writer.println(reader.getDocument());
		writer.close();
		
	}

}
