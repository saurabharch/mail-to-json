defmodule MailToJson.MailParser do


  def parse_mail_data({"multipart" = content_type_name, content_subtype_name, mail_meta, _, body}) do
    parse_mail_bodies(body)
    |> Map.merge extract_mail_meta(mail_meta)
  end


  def parse_mail_data({"text" = content_type_name, content_subtype_name, mail_meta, _, body})
    when content_subtype_name == "plain" or content_subtype_name == "html" do

    meta_data = extract_mail_meta(mail_meta)

    data = case content_subtype_name do
      "html"  -> %{"html_body"  => body}
      "plain" -> %{"plain_body" => body}
    end
    |> Map.merge meta_data
  end


  defp parse_mail_bodies([], %{}),       do: %{}
  defp parse_mail_bodies([], collected), do: collected

  defp parse_mail_bodies([body | bodies], collected \\ %{}) do
    new_collected = Map.merge collected, parse_mail_data(body)
    parse_mail_bodies(bodies, new_collected)
  end


  defp extract_mail_meta(mail_meta) do
    fields = ["From", "To", "Subject", "Date", "Message-ID"]
    Enum.reduce fields, %{}, fn(field, data)->
      case :proplists.get_value(field, mail_meta) do
        :undefined -> data
        value -> Map.put(data, field, value)
      end
    end
  end

end
