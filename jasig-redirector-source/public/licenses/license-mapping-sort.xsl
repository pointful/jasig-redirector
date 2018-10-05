<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ll="https://source.jasig.org/schemas/maven-notice-plugin/license-lookup" 
    version="1.0">
    
    <xsl:template match="/">
        <xsl:apply-templates select="ll:license-lookup"/>
    </xsl:template>
    
    <xsl:template match="ll:license-lookup">
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:apply-templates select="ll:artifact">
                <xsl:sort select="ll:groupId"/>
                <xsl:sort select="ll:artifactId"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    

</xsl:stylesheet>