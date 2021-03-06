<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:saxon="http://icl.com/saxon" xmlns:exsl="http://exslt.org/common"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
    xmlns:xtbl="xalan://com.nwalsh.xalan.Table" xmlns:lxslt="http://xml.apache.org/xslt"
    xmlns:ptbl="http://nwalsh.com/xslt/ext/xsltproc/python/Table"
    xmlns:stbl="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.Table"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="doc stbl xtbl lxslt ptbl saxon exsl xlink">

    <xsl:import href="docbook-xsl-1.78.1/xhtml5/docbook.xsl"/>
    <xsl:output method="xml" encoding="UTF-8" indent="no" omit-xml-declaration="no"/>

    <!-- default is "::=" -->
    <xsl:param name="ebnf.assignment">
        <code>=</code>
    </xsl:param>
    <xsl:param name="ebnf.statement.terminator">;</xsl:param>
    <xsl:param name="ebnf.table.bgcolor">#EEE</xsl:param>
    <xsl:param name="ebnf.table.border" select="0"/>
    <xsl:param name="formal.object.break.after">0</xsl:param>

    <xsl:param name="docbook.css.link" select="0"/>
    <xsl:param name="user.print.css"/>

    <!-- ==================================================================== -->
    <!-- toc settings                                                         -->
    <xsl:param name="generate.toc">
        book toc,title
    </xsl:param>
    <xsl:param name="toc.list.type">ol</xsl:param>
    
    <!-- ==================================================================== -->
    <!-- override gentext to get "Chapter" etc out of link labels             -->

    <xsl:param name="local.l10n.xml" select="document('')"/>
    <l:i18n xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0">
        <l:l10n language="en">
            <l:context name="xref-number-and-title">
                <l:template name="chapter" text="%t"/>
                <l:template name="section" text="%t"/>
                <l:template name="table" text="%t"/>
                <l:template name="bridgehead" text="%t"/>
            </l:context>
            <l:context name="title">
                <l:template name="note" text="note"/>
                <l:template name="caution" text="caution"/>
                <l:template name="chapter" text="%t"/>
                <l:template name="example" text="%t"/>
                <l:template name="table" text="%t"/>
            </l:context>
            <l:context name="title-unnumbered">
                <l:template name="chapter" text="%t"/>
                <l:template name="section" text="%t"/>
            </l:context>
            <l:context name="title-numbered">
                <l:template name="chapter" text="%n %t"/>
                <l:template name="section" text="%n %t"/>
            </l:context>
        </l:l10n>
    </l:i18n>
    
    <xsl:param name="admon.style"/>
    <xsl:param name="admon.textlabel">1</xsl:param>
    <xsl:param name="table.borders.with.css">0</xsl:param>
    
    <xsl:param name="toc.section.depth">8</xsl:param>
    
    <xsl:include href="shared.xsl"/>

</xsl:stylesheet>
