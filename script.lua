local username = get("username-input")
local password = get("password-input")

local loginbutton = get("login")
local registerbutton = get("register")

local result = get("result")
local balanceitem = get("balance")
local transactionsitem = get("transactions")


local token

local function formatTransactions(data)
    local formattedData = {}
    for _, transaction in ipairs(data) do
        local success, formattedTransaction = pcall(function()
            return string.format(
                "[%d] - Sender: %s, Receiver: %s, Amount: %d, Timestamp: %s\n",
                transaction.id,
                transaction.sender,
                transaction.receiver,
                transaction.amount,
                transaction.timestamp
            )
        end)
        if success then
            table.insert(formattedData, formattedTransaction)
        else
            print("Error formatting transaction:", formattedTransaction)
            -- You can choose to handle the error in any appropriate way here
        end
    end
    return table.concat(formattedData)
end




loginbutton.on_click(function()
    local body = "{"
		.. '"username": "'
		.. username.get_content()
		.. '", '
		.. '"password": "'
		.. password.get_content()
		.. '"'
		.. "}"
    print(body)
	local res = fetch({
		url = "https://bank.smartlinux.xyz/api/login",
		method = "POST",
		headers = { ["Content-Type"] = "application/json" },
		body = body,
	})
    print(res)
	if res and res.status then
		if res.status == 429 then
			result.set_content("Failed due to ratelimit.")
		else
			result.set_content("Failed due to error: " .. res.status)
		end
	elseif res and res.token then
		token = res.token
		result.set_content(
			"Login successful"
		)
		local res = fetch({
			url = "https://bank.smartlinux.xyz/api/balance",
			method = "GET",
			headers = { 
				["Content-Type"] = "application/json",
				["Authorization"] = token 
			},
		})
		balanceitem.set_content(res.balance)
		local transactionss = fetch({
			url = "https://bank.smartlinux.xyz/api/transactions",
			method = "GET",
			headers = { 
				["Content-Type"] = "application/json",
				["Authorization"] = token 
			},
		})
--[[ 		print(transactionss.transactions)
		print(formatTransactions(transactionss.transactions))
		print("finished") ]]
		transactionsitem.set_content(formatTransactions(transactionss.transactions))
	else
		result.set_content("Failed due to unknown error.")
	end
end)