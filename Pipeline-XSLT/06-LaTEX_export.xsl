<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" encoding="UTF-8" />
    
    <xsl:template match="/">
        <xsl:result-document href="outputfinale.txt" method="text">
            <xsl:text>\documentclass{article}
\usepackage{graphicx}
\usepackage{polyglossia}
\setmainlanguage{greek}
\usepackage{fontspec}
\usepackage{ulem}
\newfontfamily\greekfont{GFS Didot}

\title{Edizione delle Postille di Poliziano}

\begin{document}

\maketitle


</xsl:text>
            <xsl:apply-templates select="//div" />
            <xsl:text>
\end{document}</xsl:text>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="div">
        <xsl:text>\newline\textbf{</xsl:text>
        <xsl:if test="head">
            <xsl:value-of select="normalize-space(head)" />
        </xsl:if>
        <xsl:text>\begin{itemize}</xsl:text>    
        \item\newline { LAYOUT <xsl:value-of select="normalize-space(concat((@type),' ',(@subtype)))" />
        <xsl:if test="some $a in tokenize(@rend, '\s+') satisfies $a = 'color:red'">
            <xsl:text> in inchiostro rosso </xsl:text>
        </xsl:if>
        <xsl:if test="some $a in tokenize(@rend, '\s+') satisfies $a = 'color:brown'">
            <xsl:text> in inchiostro marrone </xsl:text>
        </xsl:if>
        }
        \item\newline SEMANTICA: 
        <xsl:if test="some $a in tokenize(@ana, '\s+') satisfies $a = '#notabile'">
            <xsl:text> \testit{notabile} </xsl:text>
        </xsl:if>
        <xsl:if test="some $a in tokenize(@ana, '\s+') satisfies $a = '#lociParalleli'">
            <xsl:text> intertestualità</xsl:text>
        </xsl:if>        
        <xsl:if test="some $a in tokenize(@ana, '\s+') satisfies $a = '#philologia'">
            <xsl:text> filologia</xsl:text>
        </xsl:if>
        <xsl:if test="some $a in tokenize(@ana, '\s+') satisfies $a = '#exegesis'">
            <xsl:text> esegesi</xsl:text>
        </xsl:if>        
        <xsl:if test="some $a in tokenize(@ana, '\s+') satisfies $a = '#deSappho'">
            <xsl:text>, testimonianza sulla figura di Saffo </xsl:text>
        </xsl:if>        
        <xsl:if test="some $a in tokenize(@ana, '\s+') satisfies $a = '#deGenuino'">
            <xsl:text>, sull'autenticità dell'epistola </xsl:text>
        </xsl:if>
        <xsl:text>}
        \end{itemize}\newline}</xsl:text>
        <xsl:apply-templates select="p" />
        <xsl:text>\newline\newline\newline</xsl:text>
    </xsl:template>
    
    <xsl:template match="p">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="persName">
        <xsl:text>\textgreek{</xsl:text>
        <xsl:apply-templates />
        <xsl:text>}</xsl:text>
    </xsl:template>

    <xsl:template match="note">
        <xsl:text>\footnote{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <xsl:template match="choice">
        <xsl:text>\textgreek{</xsl:text>
        <xsl:value-of select="normalize-space(reg)" />
        <xsl:value-of select="normalize-space(expan)" />
        <xsl:value-of select="normalize-space(corr)" />
        <xsl:text>}</xsl:text>
    </xsl:template>
       
    <xsl:template match="seg">
        <xsl:text>{\textgreek{</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>}}</xsl:text>

        <!-- Add note -->  
        <xsl:if test="./@source">
            <xsl:variable name="source" select="./@source"/>
            <xsl:variable name="bibl-text" select="//cit[@xml:id = $source]/descendant::bibl"/>
            <xsl:if test="$bibl-text">
                <xsl:text>\footnote{</xsl:text>
                <xsl:value-of select="$bibl-text"/>
                <xsl:text>}</xsl:text>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="//body/lb">
        <xsl:text> \newline </xsl:text>
    </xsl:template>

<xsl:template match="p/lb[position() > 1]">
    <xsl:text> | </xsl:text>
</xsl:template>

<xsl:template match="p/*//lb">
    <xsl:text> | </xsl:text>
</xsl:template>

<xsl:template match="del">
    <xsl:text>\sout{</xsl:text>
    <xsl:value-of select="."/>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="hi[@rend='underlined:true;']">
    <xsl:text>\underline{</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>}</xsl:text>
</xsl:template>

 <xsl:template match="unclear">
   <xsl:text>\testit{\textgreek{</xsl:text>
   <xsl:apply-templates />
     <xsl:text>}}</xsl:text>
 </xsl:template>

<xsl:template match="supplied">
    <xsl:text>[\textgreek{</xsl:text>
    <xsl:apply-templates />
     <xsl:text>}]</xsl:text>
</xsl:template>


</xsl:stylesheet>
