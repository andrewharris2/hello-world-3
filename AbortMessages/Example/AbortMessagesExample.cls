Include (Ensemble, ExampleSQL)

/// An example which demonstrates identifying and aborting some queued messages.
Class Example.AbortMessages.AbortMessagesExample Extends %RegisteredObject
{

/// Name of the queue containing messages to be aborted.
Parameter QUEUENAME = "ORM_O01_FileOperation";

/// Finds and aborts some queued messages.
ClassMethod FindAndAbortMessages()
{
	try {
		set queueName = ..#QUEUENAME
		set example = ##class(AbortMessagesExample).%New()
		set messageSet = example.FindMessagesToBeAborted()
		set queueUtil = ##class(QueueUtil).%New()
		do queueUtil.AbortSelectedQueuedMessages(queueName, messageSet)
	} catch ex {
		#dim ex As %Exception.AbstractException
		$$$LOGERROR(ex.DisplayString())
	}
}

/// Finds some queued messages which are to be aborted.
Method FindMessagesToBeAborted() As %Library.AbstractArray
{
	$$$TRACE("Finding messages to be aborted")
	set status = $$$OK
	set messageStatus = $$$eMessageStatusQueued
	set queryString = "select ID, Status from Ens.MessageHeader"
		_ " where"
		_ " status = '" _ messageStatus _ "'"
		_ " and MessageBodyClassName = 'EnsLib.HL7.Message'"
	set statement = ##class(%SQL.Statement).%New()
	set status = statement.%Prepare(queryString)
	$$$ThrowOnError(status)
	set resultSet = statement.%Execute()
	$$$THROWONRESULTERROR(resultSet)

	set messageSet = ##class(%Library.ArrayOfDataTypes).%New()
	set value = 1
	while (resultSet.%Next()) {
		set messageHeaderID = resultSet.ID
		$$$TRACE("messageHeaderID: " _ messageHeaderID)		
		set messageHeader = ##class(Ens.MessageHeader).%OpenId(messageHeaderID,, .status)
		$$$ThrowOnError(status)

		#dim messageHeader As Ens.MessageHeader
		set messageBodyID = messageHeader.MessageBodyId
		$$$TRACE("messageBodyID: " _ messageBodyID)
		set message = ##class(EnsLib.HL7.Message).%OpenId(messageBodyID,, .status)
		$$$ThrowOnError(status)

		#dim message As EnsLib.HL7.Message
		set schemaName = message.MessageTypeCategory
		$$$TRACE("schemaName: " _ schemaName)
		set messageName = message.Name
		$$$TRACE("messageName: " _ messageName)
		// The path for PID will depend on the message name. This works for 2.3.1 ORM_O01. [XXX]
		set lastName = message.GetValueAt("PIDgrp.PID:PatientName(1).familylastname", .status)
		$$$ThrowOnError(status)
		$$$TRACE("lastName: " _ lastName)
		set selected = ($extract(lastName, 1, 4) = "TEST")
		if (selected) {
			$$$TRACE("selected")
			set status = messageSet.SetAt(value, messageHeaderID)
		}
	}
	quit messageSet
}

}

