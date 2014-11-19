<?xml version="1.0"?>
<!--
           Copyright (c) 2008-2010 PDFlib GmbH. All rights reserved.
    This software may not be copied or distributed except as expressly
    authorized by PDFlib GmbH's general license agreement or a custom
    license agreement signed by PDFlib GmbH.
    For more information about licensing please refer to www.pdflib.com.

    Purpose: convert TETML to HTML
    
    Required input:
        TET 4 TETML in wordplus mode. The script includes information about the
        images for each page. To make the links for the images work
        correctly, the images must be extracted together with TETML. With the
        TET command line tool this can be accomplished like this:
                tet -i -m wordplus <input PDF document>
    
    Stylesheet parameters:
    
    debug:              0: no debug info, >0: increasingly verbose
    
    toc-generate:       0: no table of contents, 1: generate table of contents
    toc-exclude-min, toc-exclude-max:
        Specify a range of pages to exclude from the generation of the HTML
        table of contents. This can be used to prevent duplicate entries if
        also entries in the PDF table of contents are detected as headings
        because of their font size.
    
    h<n>.min-size, h<n>.max-size, with n=1..5:
        "Para" elements must include at least one character whose size is greater
        or equal to the h<n>.min-size parameter and less than or equal to the
        h<n>.max-size parameter to be recognized as a h1..h5 heading

    Version: $Id: tetml2html.xsl,v 1.6 2010/07/22 15:00:43 stm Exp $
-->

<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:tet="http://www.pdflib.com/XML/TET3/TET-3.0"
        exclude-result-prefixes="tet">
        
        <xsl:output method="html" indent="yes"/>
        
        <xsl:param name="debug">0</xsl:param>
        
        <xsl:param name="toc-generate">1</xsl:param>
        <xsl:param name="toc-exclude-min">-1</xsl:param>
        <xsl:param name="toc-exclude-max">-1</xsl:param>
        
        <xsl:param name="h1.min-size">24.9</xsl:param>
        <xsl:param name="h1.max-size">10000</xsl:param>
        
        <xsl:param name="h2.min-size">24</xsl:param>
        <xsl:param name="h2.max-size">24.8</xsl:param>
                
        <xsl:param name="h3.min-size">15</xsl:param>
        <xsl:param name="h3.max-size">23.9</xsl:param>
                
        <xsl:param name="h4.min-size">10001</xsl:param>
        <xsl:param name="h4.max-size">10000</xsl:param>
                
        <xsl:param name="h5.min-size">10001</xsl:param>
        <xsl:param name="h5.max-size">10000</xsl:param>
        
        <xsl:variable name="pdf-basename">
                <xsl:call-template name="pdf-basename">
                        <xsl:with-param name="full-pdf-name" select="/tet:TET/tet:Document/@filename" />
                </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="resources" select="/tet:TET/tet:Document/tet:Pages/tet:Resources"/>
        
        <xsl:template match="/">
		<!-- Make sure that the input TETML was prepared in wordplus mode including geometry -->
		<xsl:if test="tet:TET/tet:Document/tet:Pages/tet:Page/tet:Content[not(@granularity = 'word') or not(@geometry = 'true')]">
			<xsl:message terminate="yes">
				<xsl:text>Stylesheet tetml2html.xsl processing TETML for document '</xsl:text>
				<xsl:value-of select="tet:TET/tet:Document/@filename" />
				<xsl:text>': this stylesheet requires TETML in wordplus mode. </xsl:text>
				<xsl:text>Create the input in page mode "wordplus".</xsl:text>
			</xsl:message>
		</xsl:if>
        	<html>
        		<head>
        		<title>
        			<xsl:text>HTML version of </xsl:text>
        			<xsl:value-of select="tet:TET/tet:Document/@filename"/>
        		</title>
                        <style type="text/css">
                                .dropcap { float:left; font-size:88px; line-height:88px; padding-top:3px; padding-right:3px; }
                                <!-- The text-shadow CSS element is not honored by IE -->
                                .shadowed { text-shadow: 2px 2px 3px #000; }
                        </style>
        		</head>
        		<body>
                                <xsl:if test="$toc-generate &gt; 0">
                                        <xsl:apply-templates
                                                select="tet:TET/tet:Document/tet:Pages/tet:Page[not(@number &gt;= $toc-exclude-min and
                                                                        @number &lt;= $toc-exclude-max)]" mode="toc" />
                                </xsl:if>
        			<xsl:apply-templates select="tet:TET/tet:Document/tet:Pages/tet:Page" mode="body" />
                	</body>
                </html>
        </xsl:template>
   
        <!--
                Group of templates for generating the Table of Contents. These
                templates are all defined with mode "toc". They generate
                links to anchors for all the Para elements that are identified
                as headings. 
        -->
        <xsl:template match="tet:Page" mode="toc">
                <xsl:for-each select="tet:Content/tet:Para">
                        <xsl:choose>
                                <xsl:when test="tet:Word/tet:Box/tet:Glyph[@size &gt;= $h1.min-size and @size &lt;= $h1.max-size]">
                                        <xsl:call-template name="toc-entry">
                                                <xsl:with-param name="toc-heading" select="'h1'" />
                                        </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="tet:Word/tet:Box/tet:Glyph[@size &gt;= $h2.min-size and @size &lt;= $h2.max-size]">
                                        <xsl:call-template name="toc-entry">
                                                <xsl:with-param name="toc-heading" select="'h2'" />
                                        </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="tet:Word/tet:Box/tet:Glyph[@size &gt;= $h3.min-size and @size &lt;= $h3.max-size]">
                                        <xsl:call-template name="toc-entry">
                                                <xsl:with-param name="toc-heading" select="'h3'" />
                                        </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="tet:Word/tet:Box/tet:Glyph[@size &gt;= $h4.min-size and @size &lt;= $h4.max-size]">
                                        <xsl:call-template name="toc-entry">
                                                <xsl:with-param name="toc-heading" select="'h4'" />
                                        </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="tet:Word/tet:Box/tet:Glyph[@size &gt;= $h5.min-size and @size &lt;= $h5.max-size]">
                                        <xsl:call-template name="toc-entry">
                                                <xsl:with-param name="toc-heading" select="'h5'" />
                                        </xsl:call-template>
                                </xsl:when>
                                <!-- no xsl:otherwise as normal Paras are suppressed in the TOC -->
                        </xsl:choose>
                </xsl:for-each>
        </xsl:template>
        
        <!--
                Generate an entry for the provided Para element
                as the specified heading element $toc-heading (h1..h5)
        -->
        <xsl:template name="toc-entry">
                <xsl:param name="toc-heading" />
                
                <xsl:element name="{$toc-heading}">
                        <a>
                                <xsl:attribute name="href"><xsl:text>#</xsl:text><xsl:value-of select="generate-id()"/></xsl:attribute>
                                <xsl:apply-templates select="tet:Word/tet:Text"/>
                        </a>
                </xsl:element>
        </xsl:template>
                          
        <!--
                Group of templates to generate the text body of the document.
                The headings are identified in the same manner as in toc mode,
                only that in this case the anchors are generated through
                "id" attributes for the h1, h2, ... elements. 
        -->
        <xsl:template match="tet:Page" mode="body">
        	<xsl:if test="$debug &gt; 0">
           	        <hr/><i>
   	        	<xsl:text>[Page </xsl:text>
   	        	<xsl:value-of select="@number"/>
   	        	<xsl:text> of </xsl:text>
   	        	<xsl:value-of select="ancestor::tet:Document[1]/@filename"/>
   	        	<xsl:text>]</xsl:text>
   	        	</i>
                        <xsl:apply-templates select="tet:Exception" />
   	        </xsl:if>
                <xsl:choose>
                        <xsl:when test="tet:Content/tet:Word">
                                <p><xsl:apply-templates select="tet:Content/tet:Word/tet:Text" /></p>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:for-each select="tet:Content/tet:Para | tet:Content/tet:Table">
                                        <xsl:choose>
                                                <xsl:when test="local-name() = 'Para' and tet:Word/tet:Box/tet:Glyph[@size &gt;= $h1.min-size and @size &lt;= $h1.max-size]">
                                                        <xsl:call-template name="heading">
                                                                <xsl:with-param name="heading-type" select="'h1'" />
                                                        </xsl:call-template>
                                                </xsl:when>
                                                <xsl:when test="local-name() = 'Para' and tet:Word/tet:Box/tet:Glyph[@size &gt;= $h2.min-size and @size &lt;= $h2.max-size]">
                                                        <xsl:call-template name="heading">
                                                                <xsl:with-param name="heading-type" select="'h2'" />
                                                        </xsl:call-template>
                                                </xsl:when>
                                                <xsl:when test="local-name() = 'Para' and tet:Word/tet:Box/tet:Glyph[@size &gt;= $h3.min-size and @size &lt;= $h3.max-size]">
                                                        <xsl:call-template name="heading">
                                                                <xsl:with-param name="heading-type" select="'h3'" />
                                                        </xsl:call-template>
                                                </xsl:when>
                                                <xsl:when test="local-name() = 'Para' and tet:Word/tet:Box/tet:Glyph[@size &gt;= $h4.min-size and @size &lt;= $h4.max-size]">
                                                        <xsl:call-template name="heading">
                                                                <xsl:with-param name="heading-type" select="'h4'" />
                                                        </xsl:call-template>
                                                </xsl:when>
                                                <xsl:when test="local-name() = 'Para' and tet:Word/tet:Box/tet:Glyph[@size &gt;= $h5.min-size and @size &lt;= $h5.max-size]">
                                                        <xsl:call-template name="heading">
                                                                <xsl:with-param name="heading-type" select="'h5'" />
                                                        </xsl:call-template>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                        <xsl:apply-templates mode="body" select="." />
                                                </xsl:otherwise>
                                        </xsl:choose>
                                </xsl:for-each>
                        </xsl:otherwise>
                </xsl:choose>
                
                <xsl:if test="tet:Content/tet:PlacedImage">
                        <!--
                                Create an unordered list of images on the page 
                         -->
                        <p>
                                <span style="font-style:italic">
                                        <xsl:text>Images on page </xsl:text>
                                        <xsl:value-of select="@number"/>
                                        <xsl:text>:</xsl:text>
                                        <ul>
                                                <xsl:apply-templates mode="body" select="tet:Content/tet:PlacedImage" />
                                        </ul>
                                </span>
                        </p>
                </xsl:if>
                
        </xsl:template>

        <!-- Print out exceptions in an eye-catching color -->
        <xsl:template match="tet:Exception">
                <div style="color: red">
                        <xsl:text>Exception occurred at page level:&#xa;"</xsl:text>
                        <xsl:value-of select="." />
                        <xsl:text>"</xsl:text>
                </div>
        </xsl:template>
        
        <!--
                Generate a heading element for the provided Para element
                as the specified heading element $heading-type (h1..h5)
        -->
        <xsl:template name="heading">
                <xsl:param name="heading-type" />
                
                <xsl:element name="{$heading-type}">
                        <xsl:attribute name="id"><xsl:value-of select="generate-id()"/></xsl:attribute>
                        <xsl:apply-templates select="tet:Word/tet:Text" />
                </xsl:element>
        </xsl:template>

        <xsl:template mode="body" match="tet:Para">
                <p><xsl:apply-templates select="tet:Word/tet:Text" /></p>
        </xsl:template>
        
        <xsl:template mode="body" match="tet:Table">
        	<table border="1">
        		<tbody><xsl:apply-templates select="tet:Row" mode="body" /></tbody>
        	</table>
        </xsl:template>

        <xsl:template mode="body" match="tet:Row">
        	<tr> <xsl:apply-templates select="tet:Cell" mode="body" /> </tr>
        </xsl:template>
        
        <!-- Process tables also recursively -->
        <xsl:template mode="body" match="tet:Cell">
        	<td>
                        <xsl:if test="@colSpan">
                                <xsl:attribute name="colspan">
                                        <xsl:value-of select="@colSpan" />
                                </xsl:attribute>
                        </xsl:if>
                        <xsl:apply-templates mode="body" select="tet:Para | tet:Table | tet:PlacedImage" />
                </td>
        </xsl:template>

        <!-- 
                Print information about a placed image on the page, together
                with a link to the actual image. As the images created by TET
                are mostly not conforming to HTML, we do not put the images
                inline on the HTML page. 
         -->
        <xsl:template mode="body" match="tet:PlacedImage">
                <xsl:variable name="image-id" select="@image" />
                <xsl:variable name="image-resource"
                        select="$resources/tet:Images/tet:Image[@id = $image-id]" />
                <xsl:variable name="image-name"
                        select="concat($pdf-basename, '_', $image-id, $image-resource/@extractedAs)" />
                <xsl:variable name="colorspace" 
                        select="$resources/tet:ColorSpaces/tet:ColorSpace[@id = $image-resource/@colorspace]" />
                <li>
                        <a>
                                <xsl:attribute name="href">
                                        <xsl:value-of select="$image-name" />
                                </xsl:attribute>
                                <xsl:value-of select="$image-id" />
                        </a>
                        
                        <xsl:text>: Dimensions </xsl:text>
                        <xsl:value-of select="$image-resource/@width" />
                        <xsl:text>x</xsl:text>
                        <xsl:value-of select="$image-resource/@height" />
                        
                        <xsl:text>, </xsl:text>
                        <xsl:value-of select="$image-resource/@bitsPerComponent" />
                        <xsl:text> bits per component, colorspace '</xsl:text>
                        <xsl:value-of select="$colorspace/@name" />
                        <xsl:text>' with </xsl:text>
                        <xsl:value-of select="$colorspace/@components" />
                        <xsl:text> component(s)</xsl:text>
                </li>
        </xsl:template>
        
        <xsl:template match="tet:Text">
                <!--
                        Detect and output some text formatting options. The first
                        character of a word is output with a dropcap style if the
                        first character has the "dropcap" attribute set to true.
                        A whole word is output with a shadowed style if any
                        character has the "shadow" attribute set to true.
                        And finally a word can be output as superscript or subscript
                        if any character has the corresponding "sup" or "sub" attribute
                        set to true. As not both superscript and subscript can
                        be active at the same time, superscript is arbitrarily
                        choosen as having precedence.
                -->
                <xsl:variable name="dropcapped">
                        <xsl:choose>
                                <xsl:when test="following-sibling::tet:Box/tet:Glyph[1][@dropcap = 'true']">
                                        <span class="dropcap">
                                                <xsl:value-of select="substring(., 1, 1)"/>
                                        </span>
                                        <xsl:value-of select="substring(., 2)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                        <xsl:value-of select="."/>
                                </xsl:otherwise>
                        </xsl:choose>
                </xsl:variable>
                
                <xsl:variable name="shadowed">
                        <xsl:choose>
                                <xsl:when test="following-sibling::tet:Box/tet:Glyph[@shadow = 'true']">
                                        <span class="shadowed">
                                                <xsl:copy-of select="$dropcapped"/>
                                        </span>
                                </xsl:when>
                                <xsl:otherwise>
                                        <xsl:copy-of select="$dropcapped"/>
                                </xsl:otherwise>
                        </xsl:choose>
                </xsl:variable>
                
                <xsl:choose>
                        <xsl:when test="following-sibling::tet:Box/tet:Glyph[@sup = 'true']">
                                <sup>
                                        <xsl:copy-of select="$shadowed"/>
                                </sup>
                        </xsl:when>
                        <xsl:when test="following-sibling::tet:Box/tet:Glyph[@sub = 'true']">
                                <sub>
                                        <xsl:copy-of select="$shadowed"/>
                                </sub>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:copy-of select="$shadowed"/>
                        </xsl:otherwise>
                </xsl:choose>
                <xsl:text> </xsl:text>
        </xsl:template>

        <!-- 
                Retrieve the basename of the PDF document. The assumption is
                that it has a four-character ".pdf" suffix that is stripped off.
                Then the string behind the last "/" or "\" is taken
         -->
        <xsl:template name="pdf-basename">
                <xsl:param name="full-pdf-name" />
                <xsl:variable name="slash-normalized" select="translate($full-pdf-name, '\\', '/')" />
                <xsl:variable name="suffix-stripped" select="substring($slash-normalized, 0, string-length($slash-normalized) - 3)" />
                <xsl:call-template name="strip-dirs">
                        <xsl:with-param name="path" select="$suffix-stripped" />
                </xsl:call-template>
        </xsl:template>
        
        <xsl:template name="strip-dirs">
                <xsl:param name="path" />
                <xsl:variable name="rest" select="substring-after($path, '/')" />
                <xsl:choose>
                        <xsl:when test="string-length($rest) = 0">
                                <xsl:value-of select="$path" />
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:call-template name="strip-dirs">
                                        <xsl:with-param name="path" select="$rest" />
                                </xsl:call-template>
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:template>
</xsl:stylesheet>
